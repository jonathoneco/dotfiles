---
description: "Enter or continue the research phase of a workflow — structured exploration with indexed findings."
user_invocable: true
---

# Workflow Research

Enter or continue the research phase of a workflow. Performs structured exploration with indexed findings, dead-end tracking, and optional promotion of standalone research to permanent docs.

## Arguments

- `<name>` — the workflow slug (kebab-case)
- `[topic]` — optional focus topic for this research session. If omitted, suggest topics based on workflow title or ask what to investigate.

## Process

### Step 1: Load context

Read these files in parallel to orient:

1. `.workflows/<name>/state.json` — verify `current_phase` is `research` (or `not_started`)
2. `.workflows/<name>/research/index.md` — see what research already exists
3. `.workflows/<name>/research/dead-ends.md` — know what has been tried and failed
4. Latest checkpoint from `.workflows/<name>/research/checkpoints/` (if any) — resume from where the last session left off

Do **not** read raw research note files at this stage. The index provides sufficient orientation; read individual notes only when actively working on a related topic.

If `current_phase` is not `research` or `not_started`, report the mismatch and suggest `/workflow-status <name>` to inspect state.

### Step 2: Set phase active

If the research phase status is `not_started`, activate it:

```bash
bd set-state <epic-id> phase=research
```

Update `state.json`:
- `phases.research.status` = `"active"`
- `phases.research.started_at` = current ISO 8601 timestamp (only if first activation)
- `current_phase` = `"research"`
- `updated_at` = current ISO 8601 timestamp

### Step 3: Present and Ask

Summarize the loaded context for the user:

- **Index entries**: List topics already researched (from index.md)
- **Dead ends**: Mention any failed approaches (from dead-ends.md)
- **Checkpoint**: If resuming, highlight where the last session left off

Then direct the conversation:

- If `[topic]` was provided: "You want to research `<topic>`. Here's what's already known from the index: `<summary>`. Shall I proceed with this focus, or adjust?"
- If no topic: Present research gaps visible in the index and ask — "What would you like to investigate? Here are areas not yet covered: ..."

**Do NOT begin research (Steps 4a-4e) until the user confirms a topic.**

### Step 4: Research workflow

For each confirmed research topic, follow this sequence:

#### 4a: Search closed beads and prior futures first

Always start here. Closed issues document what was built, decided, and abandoned. Prior futures document what was researched and deferred.

```bash
bd search '<keyword>' --limit 10
```

Then `bd show <id>` for each relevant match. Cross-reference against the Deprecated Approaches table in CLAUDE.md — skip issues about replaced technologies unless investigating why they were abandoned.

Also scan `docs/futures/` for relevant prior futures from archived workflows:

```bash
grep -rl '<keyword>' docs/futures/ 2>/dev/null
```

If matches are found, read the relevant entries. Prior futures contain pre-researched enhancement descriptions with context, prerequisites, and domain tags — they may answer questions or provide a starting point for the current research.

#### 4b: Explore codebase (parallel agents)

Spin up parallel Explore agents — one per relevant code area. Each gathers: file paths, existing patterns, interface shapes, test coverage.

Name agents as **domain experts** matching the investigation area (e.g., `migration-analyst`, `ownership-model-analyst`, `auth-specialist`), not generic names. This primes better reasoning.

For broad topics spanning 3+ code areas, launch all agents concurrently and synthesize results after they complete. Do not wait for one agent before launching the next.

#### 4c: Web search

If the topic requires external research (technology choices, best practices, competitive analysis, API documentation), use web search to gather current information.

#### 4d: Write findings

Create `.workflows/<name>/research/<topic-slug>.md`:

```markdown
# Research: <Topic>

## Key Findings
- [Finding with file paths and evidence]

## Relevant Code
- `internal/path/to/file.go` — [what it does]

## Prior Art (from beads)
- rag-xxxx: [relevant closed issue summary]

## Implications for Design
- [How this affects architecture decisions]

## Open Questions
- [Unresolved questions]
```

#### 4e: Update index

Add a one-line summary to `.workflows/<name>/research/index.md`:

```
| <topic> | <one-line summary> | active | research/<topic-slug>.md |
```

#### 4f: Check in with the user

After completing one topic, present the result and ask:

"Topic `<topic>` researched and indexed. What next?"
- Research another topic
- Capture a future enhancement (if out-of-scope improvements were identified)
- Promote this finding to permanent docs
- Save a checkpoint
- End the research phase

If the research identified improvements that are out of scope for the current workflow, proactively suggest capturing them: "This research identified `<enhancement>` as a potential future improvement. Want me to capture it with `/workflow-future`?"

**Do not** proceed to the next topic autonomously. Wait for the user to direct.

### Step 5: Research promotion

When a research note has standalone value beyond this workflow (edge case analysis, infrastructure assessment, competitive research, technology evaluation), offer to promote it:

1. Copy to `docs/research/<workflow-name>-<topic>.md`
2. Update the corresponding index.md entry with a `[promoted]` marker and link to the permanent location

Only offer promotion — do not promote automatically. The user decides what belongs in permanent docs.

### Step 6: Contextual tool offers

Based on what is being researched, proactively suggest next steps:

| Signal | Suggestion |
|--------|------------|
| Code path mentioned but not traced | "Want me to spin up Explore agents to trace this code path?" |
| External technology being evaluated | "Should I search the web for best practices on this?" |
| Architecture decision referenced | "Want me to check closed beads issues for prior decisions?" |
| Multiple related topics identified | "I can research these topics in parallel — want me to proceed?" |

### Step 7: Phase completion

When research feels comprehensive (key questions answered, open questions documented, dead ends recorded), suggest running `/workflow-checkpoint --phase-end` to generate the handoff prompt for the plan phase.

The handoff prompt should contain:
- Research summary (distilled from index.md)
- Dead ends and why they failed
- Future enhancements captured (from futures.md, if any)
- List of promoted docs with permanent locations
- Open questions for the planner
- Explicit instructions for what the planning phase should produce

## Key principles

- **Closed issues before code exploration.** Beads issues contain decisions, rationale, and file paths. They are faster and richer than grep for understanding what exists and why.
- **Index is the map.** The research index should give any reader a complete picture of what was investigated without opening individual notes. Keep summaries sharp.
- **Dead ends are findings.** A failed approach is a research result. Record it in dead-ends.md immediately when discovered — do not wait for session end.
- **Promote selectively.** Not every research note needs to live in permanent docs. Promote only notes with standalone reference value beyond the workflow lifecycle.
- **Parallel exploration.** When multiple topics are independent, research them concurrently using parallel Explore agents rather than sequentially.
- **User directs topic selection.** Never begin researching a topic without explicit confirmation. Present what's known and what's missing, then wait.
