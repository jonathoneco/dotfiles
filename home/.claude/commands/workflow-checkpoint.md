---
description: "Save a mid-session checkpoint or end a phase — captures progress, generates handoff prompts for next session."
user_invocable: true
---

# Workflow Checkpoint

Save current session progress for continuity across sessions. Optionally mark a phase as complete and generate a handoff prompt for the next phase.

## Arguments

- `[--phase-end]` — if present, marks the current phase as complete and generates a handoff prompt for the next phase.

## Process

### Step 1: Detect active workflow

Scan `.workflows/*/state.json` for a workflow with an `active` or `in_progress` phase status. If none found, report the error and suggest running `/workflow-status` to inspect state.

If multiple workflows have active phases, list them and ask the user to specify.

### Step 2: Determine current phase

Read `current_phase` from state.json. Confirm the phase status is `active` or `not_started` (if `not_started`, update it to `active` and set `started_at` to now).

### Step 3: Generate checkpoint file

Create `.workflows/<name>/<phase>/checkpoints/<YYYY-MM-DD-HHMMSS>.md` with the following structure:

```markdown
# Checkpoint: <phase> — <YYYY-MM-DD HH:MM>

## Accomplished This Session
- [Summarize what was done based on conversation context]
- [Files created or modified]
- [Decisions made]

## Files Modified
- `path/to/file` — brief description of changes
- `path/to/file` — brief description of changes

## Remaining Work
- [What still needs to be done in this phase]
- [Incomplete items or next steps]

## Open Questions
- [Unresolved questions or decisions pending user input]
- [Technical uncertainties]

## Resumption Prompt
> [A self-contained prompt that a new Claude Code session could use to pick up exactly where this one left off. Include: what was accomplished, what's next, key files to read first, any decisions currently in flight. This prompt should be detailed enough that the next session needs no additional context beyond reading the referenced files.]
```

Synthesize each section from conversation context. If critical information is missing, ask the user before writing the checkpoint. The **Resumption Prompt** is the most important section — it must be self-contained and actionable.

**Before writing the file**, present the draft to the user — specifically highlight the **Resumption Prompt** section. Ask: "Here's the draft checkpoint. Does the resumption prompt capture where we are? Anything to add or correct?"

**Do NOT write the checkpoint file until the user approves the content.**

### Step 4: Update state.json

Add a session entry to the current phase's `sessions` array:

```json
{
  "started_at": "<ISO 8601 — session start or best estimate>",
  "checkpoint_file": "<phase>/checkpoints/<timestamp>.md"
}
```

Update `updated_at` to the current time.

### Step 5: If `--phase-end` is specified

Perform these additional steps:

#### 5a: Generate handoff prompt

Write `.workflows/<name>/<phase>/handoff-prompt.md`:

```markdown
# Handoff: <phase> → <next-phase>

## What This Phase Produced
- [Summary of all deliverables from this phase]
- [Key artifacts and their file paths]

## Key Artifacts
| File | Purpose |
|------|---------|
| `.workflows/<name>/<phase>/...` | Description |
| `docs/feature/<name>/...` | Description |

## Decisions Made
- [Decision 1 — rationale]
- [Decision 2 — rationale]

## Open Questions Carried Forward
- [Questions the next phase needs to address]

## Instructions for Next Phase (<next-phase>)
[Explicit, actionable instructions for what the next phase session should do. Include:
- What to read first
- What to produce
- Constraints or requirements from this phase's findings
- Specific files to create or modify]

## Files to Read First
1. `path/to/most/important/file`
2. `path/to/second/file`
3. `path/to/third/file`
```

This handoff prompt is the core meta-prompt mechanism: the current session (with deep context from doing the work) generates optimal instructions for the next session (starting cold).

**Before writing the file**, present the handoff prompt draft to the user. Ask: "This handoff prompt will guide the next phase session. Review it — anything missing or wrong?"

**Do NOT advance phase state until the handoff prompt is approved.**

#### 5b: Update state.json

- Set current phase `status` to `completed` and `completed_at` to now
- Set current phase `handoff_prompt` to the handoff file path
- Advance `current_phase` to the next phase in order: research -> plan -> spec -> decompose -> implement
- If `current_phase` was already `implement`, leave it as `implement` (final phase)

#### 5c: Create beads gate (optional review point)

```bash
bd create --title="[Gate] <name>: <phase> → <next-phase>" --type=task --priority=2
```

Store the gate issue ID in the completed phase's `gate_id` field in state.json.

### Step 6: Git commit

```bash
git add .workflows/<name>/
git commit -m "chore: checkpoint workflow <name> (<phase>)"
```

If `--phase-end` was used, adjust the message:

```bash
git commit -m "chore: complete <phase> phase for workflow <name>"
```

### Step 7: Report

Confirm what was saved and suggest next steps:

- **Mid-session checkpoint**: "Checkpoint saved. Resume with `/workflow-reground <name>` in the next session."
- **Phase end**: "Phase `<phase>` complete. Handoff prompt written. Start next phase with `/workflow-<next-phase> <name>` or review the gate issue `<gate-id>` first."

## Key principles

- **The resumption prompt is everything.** A checkpoint without a good resumption prompt is just a log entry. Invest time in making it self-contained and actionable.
- **Handoff prompts bridge sessions.** The current session has all the context — the next session has none. The handoff prompt is the only bridge. Make it thorough.
- **Phases are sequential.** Advancing to the next phase is a one-way operation. If the user needs to revisit a completed phase, they should update state.json manually.
- **Always present checkpoint content for review.** The resumption prompt and handoff prompt are the most critical artifacts — never commit them without user sign-off.
