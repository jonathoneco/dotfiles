---
description: "Deep work — multi-session initiative with research, planning, specs, and phased implementation"
user_invocable: true
---

# /work-deep $ARGUMENTS

Multi-session initiative. Pre-selects Tier 3, runs assessment to confirm, then routes through 7 steps: assess → research → plan → spec → decompose → implement → review.

This command replaces 13 `workflow-*` commands with step-based routing.

## Step 1: Detect Active Task

Scan `.work/` for `state.json` files where `archived_at` is null.

- **Active Tier 3 task exists**: Resume it. Read `current_step` and jump to the Step Router.
- **Active task of different tier exists**: "You have an active Tier <N> task '<name>'. Continue with it, or archive it and start a new one?"
- **No active task**: Proceed to assessment.
- **`$ARGUMENTS` references a beads issue**: Read issue details with `bd show`.

## Step 2: Assessment (Tier 3 pre-selected)

Apply the 3-factor depth assessment. If assessment agrees (score 4+): proceed. If disagrees: present mismatch, user decides.

## Step 3: State Initialization

1. Derive name from title (kebab-case, max 40 chars, unique)
2. Capture `base_commit`: `git rev-parse HEAD`
3. Create `.work/<name>/` directory
4. Write `state.json`:
   - `tier`: 3
   - `steps`: `["assess", "research", "plan", "spec", "decompose", "implement", "review"]`
   - `step_status`: assess=`completed`, research=`active`, all others=`not_started`
   - `current_step`: `research`
   - `assessment`: populated
5. Create beads epic and initial issue:
   ```bash
   bd create --title="<title>" --type=epic --priority=1
   bd create --title="[Research] <title>" --type=task --priority=2
   bd update <research-id> --status=in_progress
   ```
6. Create directories:
   - `docs/feature/<name>/`
   - `.work/<name>/research/`
   - `.work/<name>/plan/`
   - `.work/<name>/specs/`
   - `.work/<name>/streams/`
7. Store `beads_epic_id`, `docs_path`, `issue_id` in state.json

## Step Router

Read `current_step` from state.json and execute the matching section below.

---

### When current_step = "research"

Structured exploration to build understanding before planning.

**Process:**

1. **Read the task context**: Review `$ARGUMENTS`, beads issue details, and any conversation context.

2. **Structured exploration via parallel subagents**: Launch Explore agents to investigate aspects of the task. Spawn with `skills: [work-harness, code-quality]`.

3. **Research notes**: For each finding, create a note in `.work/<name>/research/` and index it in `.work/<name>/research/index.md`:
   ```markdown
   | Topic | Summary | Status | File |
   |-------|---------|--------|------|
   | <topic> | <one-line summary> | <explored|dead-end|future> | `<filename>.md` |
   ```

4. **Dead ends**: If an approach fails, document it in `.work/<name>/research/dead-ends.md` (same format as `/work-redirect`). Do NOT re-investigate documented dead ends.

5. **Futures**: If research reveals deferred enhancements, capture them in `.work/<name>/research/futures.md` with title, horizon (next/quarter/someday), domain, and 2-4 sentence description.

6. **Handoff prompt**: When research is sufficient, generate `.work/<name>/research/handoff-prompt.md`:
   - What this step produced (topic summaries, key findings)
   - Key artifacts and paths
   - Decisions made during research
   - Open questions to address in planning
   - Instructions for the plan step

7. **Gate review**: Create beads gate issue:
   ```bash
   bd create --title="[Gate] <name>: research → plan" --type=task --priority=2
   ```
   Store `gate_id` in step_status.

8. **Advance**: Use `/work-checkpoint --step-end` to advance to plan step, or present the handoff prompt and ask user if ready to advance.

---

### When current_step = "plan"

Synthesize research into an architecture document.

**Process:**

1. **Read research handoff**: Read `.work/<name>/research/handoff-prompt.md` — this is the primary input. Do NOT re-read individual research notes (the handoff is the firewall).

2. **Write architecture document**: Create `docs/feature/<name>/architecture.md`:
   - Problem statement and goals
   - Component map with scope estimates
   - Data flow diagrams (text-based)
   - Technology choices with rationale
   - Open questions resolved from research
   - New questions deferred to spec

3. **Present for review**: Show the architecture to the user. Ask: "Does this capture the design correctly?"

4. **Handoff prompt**: Generate `.work/<name>/plan/handoff-prompt.md`:
   - What this step produced
   - Architecture document location
   - Component list for spec writing
   - Instructions for spec step

5. **Gate review and advance**: Create gate issue. Use `/work-checkpoint --step-end`.

---

### When current_step = "spec"

Write detailed implementation specifications per component.

**Process:**

1. **Read plan handoff**: Read `.work/<name>/plan/handoff-prompt.md`.

2. **Cross-cutting contracts**: Write `docs/feature/<name>/00-cross-cutting-contracts.md` — shared schemas, interfaces, naming conventions consumed by all specs.

3. **Numbered specs**: For each component from the architecture's component map, write `docs/feature/<name>/NN-<slug>.md`:
   - Overview and scope
   - Implementation steps with acceptance criteria
   - Interface contracts (exposes/consumes)
   - Files to create/modify
   - Testing strategy

4. **Spec index**: Track in `.work/<name>/specs/index.md`:
   ```markdown
   | Spec | Title | Status | Dependencies |
   |------|-------|--------|-------------|
   | 00 | Cross-cutting contracts | complete | — |
   | 01 | <slug> | complete | 00 |
   ```

5. **Dependency ordering**: Establish which specs can be written in parallel vs sequentially.

6. **Handoff prompt and gate**: Generate `.work/<name>/specs/handoff-prompt.md`. Create gate issue. Use `/work-checkpoint --step-end`.

---

### When current_step = "decompose"

Break specs into executable work items with a concurrency map.

**Process:**

1. **Read spec handoff**: Read `.work/<name>/specs/handoff-prompt.md`.

2. **Create beads issues**: For each work item from specs:
   ```bash
   bd create --title="[<tag>] W-NN: <title>" --type=task --priority=2
   ```
   Set dependencies between issues to match spec dependency ordering.

3. **Concurrency map**: Identify which streams can run in parallel:
   - Group work items into streams (one per independent workstream)
   - Identify phase ordering (which streams must complete before others)
   - Document the DAG and critical path

4. **Stream execution documents**: For each stream, write a self-contained execution doc in `.work/<name>/streams/` or `docs/feature/<name>/phase-N/`:
   - Prerequisites and dependencies
   - Implementation steps with acceptance criteria
   - Files to create/modify
   - Interface contracts
   - Merge gate checklist

5. **Issue manifest**: Create `.work/<name>/streams/manifest.jsonl` mapping work items to beads IDs, streams, and phases.

6. **Handoff prompt and gate**: Generate `.work/<name>/streams/handoff-prompt.md`. Create gate issue.

---

### When current_step = "implement"

Execute the implementation plan from decompose.

**Process:**

1. **Read decompose handoff**: Read `.work/<name>/streams/handoff-prompt.md`.

2. **Stream execution**: Work through streams using `bd ready` to find unblocked issues:
   ```bash
   bd ready                              # Find next unblocked work
   bd update <id> --status=in_progress   # Claim it
   # ... implement per stream doc ...
   bd close <id> --reason="<summary>"    # Close when done
   ```

3. **Parallel execution** (optional): For independent streams, use parallel worktrees:
   ```bash
   git worktree add .worktrees/<name>-stream-N -b workflow/<name>-stream-N $(git branch --show-current)
   ```

4. **Checkpoints**: Use `/work-checkpoint` at session boundaries. Multi-session implementation is normal for Tier 3.

5. **Skill propagation**: When spawning implementation subagents: `skills: [work-harness, code-quality]`

6. **Verification**: Run `make test && make build` after each stream or logical unit.

7. **Advance**: When all work items are closed, advance to `review`.

---

### When current_step = "review"

Mandatory full review before archive.

**Process:**

1. **Run `/work-review`**: This is mandatory for Tier 3. The review command spawns specialist agents, collects findings, and writes to `.review/findings.jsonl`.

2. **Address findings**: All critical findings must be fixed. Important findings must be fixed or have beads issues created for deferred resolution.

3. **Re-review**: After fixes, re-run `/work-review` to reconcile.

4. **On clean review** (no critical OPEN findings): Mark `review` as `completed`.

5. **Archive**: Task remains active until `/work-archive`. The archive gate requires all critical AND important findings to be FIXED or have `beads_issue_id`.

## Escalation Handling

Already Tier 3, so escalation is rare. If needed, the user can manually adjust state.json.

## Skill Propagation

- **Implementation agents**: `skills: [work-harness, code-quality]`
- **Review agents** (via `/work-review`): `skills: [code-quality]` only
- **Research agents**: `skills: [work-harness, code-quality]`

## Session Boundaries

Tier 3 tasks span many sessions. Key patterns:
- **Starting a session**: Run `/work-deep` — it detects the active task and resumes at `current_step`
- **Ending a session**: Run `/work-checkpoint` to save progress
- **After compaction**: Run `/work-reground` to recover context
- **Dead ends**: Run `/work-redirect` to document failed approaches
