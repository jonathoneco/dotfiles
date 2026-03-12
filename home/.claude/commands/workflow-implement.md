---
description: "Enter implementation — generate execution prompts for single issues, streams, or parallel worktree sessions."
user_invocable: true
---

# Workflow Implement

Enter the implementation phase of a workflow. Supports four modes: pick up the next ready issue, target a specific issue, execute a full stream, or launch parallel worktree sessions for concurrent streams.

## Arguments

- `<name>` — the workflow slug (kebab-case)
- `[mode]` — one of:
  - (omitted) or `next` — pick the highest-priority unblocked issue
  - `<issue-id>` — target a specific beads issue
  - `stream <N>` — execute an entire stream from its execution document
  - `parallel` — identify and launch parallel worktree sessions for all unblocked streams

## Process

### Step 1: Load context

Read these files in parallel:

1. `.workflows/<name>/streams/handoff-prompt.md` (if exists) — primary context from decompose
2. `.workflows/<name>/state.json` — verify phase state
3. `.workflows/<name>/issues/manifest.jsonl` — map between issues, specs, and streams

Check beads status for this workflow:

```bash
bd ready
bd list --status=open --label=workflow:<name>
```

If `current_phase` is not `implement` and the decompose phase is not `completed`, report the mismatch and suggest `/workflow-status <name>`.

### Step 2: Set phase active

```bash
bd set-state <epic-id> phase=implement
```

Update `state.json`:
- `phases.implement.status` = `"active"`
- `phases.implement.started_at` = current ISO 8601 timestamp (only if first activation)
- `current_phase` = `"implement"`
- `updated_at` = current ISO 8601 timestamp

### Step 3: Execute selected mode

---

#### Mode: `next` (default)

1. Run `bd ready` and filter results by `workflow:<name>` label
2. Select the highest-priority unblocked issue
3. Look up the issue in `manifest.jsonl` to find its stream and spec
4. Read the relevant stream execution doc from `docs/feature/<name>/`
5. Generate a focused implementation prompt (see Step 4)
6. Present the prompt to the user: "Here's the implementation plan for `<issue>`. Ready to proceed, or want to adjust the approach?"
7. **Do NOT claim the issue or begin coding until the user confirms.**
8. On confirmation, claim the issue:
   ```bash
   bd update <issue-id> --status=in_progress
   ```
9. Begin implementation

---

#### Mode: `<issue-id>`

1. Read the specific issue: `bd show <issue-id>`
2. Look up the issue in `manifest.jsonl` to find its stream and spec references
3. Read the relevant stream execution doc
4. Generate a targeted implementation prompt (see Step 4)
5. Present the prompt to the user: "Here's the implementation plan for `<issue-id>`. Ready to proceed, or want to adjust the approach?"
6. **Do NOT claim the issue or begin coding until the user confirms.**
7. On confirmation, claim the issue:
   ```bash
   bd update <issue-id> --status=in_progress
   ```
8. Begin implementation

---

#### Mode: `stream <N>`

1. Find the matching stream doc: search `docs/feature/<name>/phase-*/stream-<N>-*.md`
2. Read the full stream execution document
3. List all work items in the stream with their beads issue IDs (from manifest)
4. Present the execution plan: work item list, scope, dependencies, and approach
5. Ask: "This stream has N work items. Here's the execution plan: ... Proceed?"
6. **Do NOT claim issues or begin coding until the user confirms.**
7. If the stream touches multiple domains (e.g., handlers + services + migrations, frontend + backend), **proactively spin up an agent team** rather than just suggesting it. Name agents as domain experts:
   ```
   This stream touches handlers, services, and migrations. Launching a team:
   - api-expert: handlers + service layer (read-write)
   - database-architect: migrations + queries (read-write)
   - integration-reviewer: verify contracts match across domains (Explore, read-only)
   ```
   The review agent runs after the implementation agents complete, checking for interface mismatches, missing error handling, and correctness issues.
8. Claim all stream issues:
   ```bash
   bd update <issue-1> --status=in_progress
   bd update <issue-2> --status=in_progress
   ```
9. Execute work items in the order defined by the stream doc, closing each as completed:
   ```bash
   bd close <issue-id> --reason="<what was implemented>"
   ```

---

#### Mode: `parallel`

1. Identify all streams with no remaining blockers:
   - Check `manifest.jsonl` for issue statuses
   - A stream is unblocked when all issues in its "Depends on" streams are closed
2. For each unblocked stream:
   - Read its stream execution doc
   - Generate a self-contained execution prompt
   - Assign a branch name: `workflow/<name>-stream-N`
3. Present the execution plan:
   ```
   Unblocked streams ready for parallel execution:

   Stream 2: <title> -- branch: workflow/<name>-stream-2
     Work items: W-03, W-04 (scope: M)
   Stream 3: <title> -- branch: workflow/<name>-stream-3
     Work items: W-05 (scope: S)
   Stream 4: <title> -- branch: workflow/<name>-stream-4
     Work items: W-06, W-07 (scope: M)

   Launch 3 worktree sessions?
   ```
4. On approval, determine the current branch and provide worktree setup instructions for each stream:
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   git worktree add .worktrees/<name>-stream-N -b workflow/<name>-stream-N "$CURRENT_BRANCH"
   cd .worktrees/<name>-stream-N
   # Start Claude Code and run: /workflow-implement <name> stream N
   ```
   The `"$CURRENT_BRANCH"` start-point is critical — without it, worktrees may be based on `main` or a detached HEAD instead of the feature branch where workflow changes live.
5. After sessions complete, show progress:
   ```bash
   bd list --status=open --label=workflow:<name>
   ```

---

### Step 4: Implementation prompt structure

All modes generate prompts following this consistent structure:

```markdown
# Implementation: <title>

## Context
[Brief summary of what this implements and where it fits in the workflow]

## Read First
[Ordered list of files to read for context — from the stream doc's
"Existing Code Context" section]
1. `internal/services/existing.go` -- existing patterns
2. `docs/feature/<name>/NN-<slug>.md` -- spec details
3. `docs/feature/<name>/00-cross-cutting-contracts.md` -- shared interfaces

## Execute
[Ordered steps from the stream doc, each with acceptance criteria]

### Step 1: <title>
[Implementation instructions]
- [ ] Acceptance: <criterion>

### Step 2: <title>
...

## Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|

## Verify
- `make test` -- all tests pass
- `make build` -- compiles cleanly
- `make lint` -- no lint issues
- `make fmt` -- code formatted

## Beads
- Claim: `bd update <id> --status=in_progress`
- Close: `bd close <id> --reason="<what was done>"`
- Sync: `bd sync`
```

### Step 5: Post-implementation

After completing work (any mode):

1. Run verification commands (adapt to project — e.g., `make test && make build && make lint`, or project-specific equivalents)
2. **Spin up a review agent** to check completed work for regressions, missed edge cases, and code quality rule violations (see project rules). Use `/review` for multi-file changes.
3. Close completed issues:
   ```bash
   bd close <issue-id> --reason="<what was implemented>"
   ```
4. Check if completing this work unblocks downstream streams:
   ```bash
   bd ready --label=workflow:<name>
   ```
5. Suggest next action:
   - If more ready issues exist: "Run `/workflow-implement <name> next` for the next issue"
   - If parallel streams are unblocked: "Streams N and M are now unblocked. Run `/workflow-implement <name> parallel`"
   - If all issues are closed: "All work items complete. Run `/workflow-archive <name>` to archive the workflow"

## Key principles

- **Stream docs are the authority.** During implementation, the stream execution document is the primary reference. Do not re-read the architecture doc or specs unless the stream doc explicitly directs you to.
- **Claim before coding.** Always `bd update --status=in_progress` before touching any file. This prevents conflicts in multi-session/worktree setups.
- **Close incrementally.** Close each work item as it is completed, not all at the end. This unblocks downstream work sooner.
- **Verify continuously.** Run `make test` and `make build` after each work item, not just at the end of a stream. Catching failures early is cheaper than debugging at integration time.
- **Parallel sessions need branches from the current branch.** Never run parallel implementation on the same branch. Each worktree session gets its own branch derived from the workflow name and stream number. Always specify the current feature branch as the start-point when creating worktrees — omitting it can cause git to base the worktree on `main` or a detached HEAD, missing workflow changes.
- **Present the plan before coding.** Every implementation mode generates a prompt and presents it for user review before claiming issues or writing code.
