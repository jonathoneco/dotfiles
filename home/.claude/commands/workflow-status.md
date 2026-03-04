---
description: "Show the current state of a workflow — phases, sessions, beads status, and suggested next action."
user_invocable: true
---

# Workflow Status

Read-only status display for a workflow. Shows phase progress, artifact counts, and suggests the next action. Makes no state changes.

## Arguments

- `[name]` — optional workflow slug. If omitted, auto-detect from `.workflows/`.

## Process

### Step 1: Resolve workflow name

If `[name]` is provided, use it directly. Otherwise:

1. List directories in `.workflows/`.
2. If exactly one exists, use it.
3. If multiple exist, list them with their titles (from each `state.json`) and ask the user to specify.
4. If none exist, report that no workflows are initialized and suggest `/workflow-start`.

### Step 2: Read state

Read `.workflows/<name>/state.json`. Extract:
- `title`, `current_phase`, `beads_epic_id`
- Each phase's `status`, `sessions` count, timestamps

### Step 3: Read beads epic status

```bash
bd show <epic-id>
```

Extract the epic's current status and any child issue counts.

### Step 4: Count artifacts per phase

Use file system checks to count what exists:

| Phase | What to count |
|-------|---------------|
| Research | Files in `.workflows/<name>/research/` excluding `index.md`, `dead-ends.md`, `handoff-prompt.md`, and the `checkpoints/` directory |
| Plan | Whether `docs/feature/<name>/architecture.md` exists |
| Spec | Count `NN-*.md` files in `docs/feature/<name>/` (numbered spec files) |
| Decompose | Count `phase-N-*.md` and `phase-N/stream-*.md` files in `.workflows/<name>/streams/` |
| Implement | Count child issues closed vs total from beads (filter by `workflow:<name>` label) |

### Step 5: Display compact table

Format the output as:

```
Workflow: <name> — <title>
Epic: <epic-id> (<status>)

Phase        | Status      | Sessions | Artifacts | Last Activity
-------------|-------------|----------|-----------|---------------
Research     | completed   | 3        | 5 notes   | 2026-02-28
Plan         | completed   | 1        | arch.md   | 2026-03-01
Spec         | active      | 2        | 4 specs   | 2026-03-01
Decompose    | not_started | 0        | —         | —
Implement    | not_started | 0        | —         | —
```

Use the most recent `completed_at`, checkpoint timestamp, or `started_at` for "Last Activity". Show `—` for phases with no activity.

### Step 6: Suggest next action

Based on the current state, recommend one of:

| Condition | Suggestion |
|-----------|------------|
| Current phase is `active` or `in_progress` | "Continue with `/workflow-<phase> <name>`" |
| Current phase is `completed`, next is `not_started` | "Ready for next phase: `/workflow-<next-phase> <name>`" |
| All phases complete | "All phases complete. Consider archiving with `/workflow-archive <name>`" |
| Research phase with 5+ notes and no checkpoint | "Consider checkpointing progress: `/workflow-checkpoint`" |
| A gate exists and is pending review | "Phase gate pending review — check beads issue `<gate-id>`" |

## Key principles

- **Read-only.** This command never modifies state.json, beads issues, or any files.
- **Fast orientation.** The output should give a complete picture in under 10 seconds of reading.
- **Actionable.** Always end with a concrete next step the user can take.
