---
description: "Re-read current phase artifacts to recover context — use after context compaction or at session start."
user_invocable: true
---

# Workflow Reground

Read-only context recovery. Loads the minimal set of artifacts needed to resume work in the current phase. Use this at the start of a new session or after context compaction to get back up to speed without re-reading raw research files.

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

Read `.workflows/<name>/state.json`. Extract `current_phase`, phase statuses, and `beads_epic_id`.

### Step 3: Load phase-specific context

Read the files listed below based on `current_phase`. Use subagents for parallel reads when multiple files are involved. **Do NOT read files not listed for the current phase** — the whole point is controlled, minimal context loading.

#### Research phase

| File | Purpose |
|------|---------|
| `.workflows/<name>/research/index.md` | Summaries of all research — this is the context-rot firewall. Do NOT read individual research note files. |
| `.workflows/<name>/research/dead-ends.md` | Approaches already tried and abandoned |
| Latest file in `.workflows/<name>/research/checkpoints/` | Most recent session's resumption prompt |

#### Plan phase

| File | Purpose |
|------|---------|
| `.workflows/<name>/research/handoff-prompt.md` | Instructions from the research phase |
| `.workflows/<name>/research/index.md` | Research summaries for reference |
| `docs/feature/<name>/architecture.md` | Architecture document (if exists) |

#### Spec phase

| File | Purpose |
|------|---------|
| `.workflows/<name>/plan/handoff-prompt.md` | Instructions from the plan phase |
| `docs/feature/<name>/architecture.md` | Architecture decisions |
| `.workflows/<name>/specs/index.md` | Spec index (if exists) |

#### Decompose phase

| File | Purpose |
|------|---------|
| `.workflows/<name>/spec/handoff-prompt.md` | Instructions from the spec phase |
| `.workflows/<name>/specs/index.md` | Spec summaries |
| List `docs/feature/<name>/` directory | Existing spec files for reference |

#### Implement phase

| File | Purpose |
|------|---------|
| `.workflows/<name>/streams/handoff-prompt.md` | Instructions from the decompose phase |
| Output of `bd ready` filtered by workflow label | Current actionable beads issues |
| List `docs/feature/<name>/` directory | Stream docs and specs for reference |

If a listed file does not exist, note its absence but continue loading the others. Missing files are normal for early-phase workflows.

### Step 4: Present focused summary

After reading all relevant files, present a concise summary:

```
## Workflow: <name> — <title>
**Current phase:** <phase> (<status>)

### Where We Are
[2-3 sentence summary of current state based on loaded artifacts]

### What's Done
- [Key completed items from checkpoints/handoff prompts]

### What's Next
- [Immediate next steps from resumption prompt or handoff instructions]

### Key Files
- `path/to/file` — what it contains
- `path/to/file` — what it contains
```

Keep this summary brief. The user can read individual files for more detail.

### Step 5: No state changes

This command is purely a context-loading operation. It does not modify state.json, create files, or update beads issues.

## Key principles

- **Index.md is the firewall.** During the research phase, never read individual research note files. The index.md file exists precisely to summarize them without consuming context window space. This is the single most important rule of this command.
- **Minimal context, maximum orientation.** Load only what is needed for the current phase. Earlier phases are summarized by their handoff prompts — do not re-read their raw artifacts.
- **Handoff prompts are primary.** When entering a new phase, the previous phase's handoff prompt is the most important file to read. It was written by a session with full context specifically to bootstrap the next session.
- **Read-only, always.** If something needs to be updated, use `/workflow-checkpoint` or edit files directly. This command only reads and summarizes.
- **Subagents for parallel reads.** When loading multiple files, use parallel subagent reads to keep the main context window lean and reduce latency.
