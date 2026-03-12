# 01: workflow-help Command

| Field | Value |
|-------|-------|
| Source | architecture.md, Component 1 |
| Depends on | — (independent) |
| Blocks | — |
| Estimated scope | S |

## Overview

A read-only command that explains the workflow harness (no-args mode) and provides contextual "what to do next" guidance for a specific workflow (with-name mode). Defers all status data (artifact counts, session counts, timestamps) to `/workflow-status`.

## Existing Code Context

- `home/.claude/commands/workflow-status.md` — closest template for command structure. Uses `description` + `user_invocable: true` frontmatter, `## Arguments`, `## Process`, `## Key principles` body.
- `home/.claude/commands/workflow-reground.md` — reads phase-specific artifacts for context recovery. workflow-help reads similar files but for guidance rather than context loading.
- `home/.claude/commands/workflow-start.md` — referenced in the "getting started" section of educational content.

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `home/.claude/commands/workflow-help.md` | Create | The command file — single markdown file with frontmatter |

## Implementation Steps

### 1. Create the command file with exact frontmatter

```yaml
---
description: "Explain the workflow harness and how to use it, or get contextual guidance for a specific workflow."
user_invocable: true
---
```

### 2. Write the title and description

```markdown
# Workflow Help

Explain the workflow harness (no args) or provide contextual "what to do next" guidance for a specific workflow (with name). This command is read-only — it never modifies state.
```

### 3. Write the Arguments section

```markdown
## Arguments

- `[name]` — optional workflow slug. If provided, loads that workflow's state and generates contextual guidance. If omitted, displays educational content about the harness.
```

### 4. Write the Process section — Mode A (no args)

When invoked without arguments, output the following static educational content directly (no file reads needed):

#### Section 1: What is a workflow?

Explain in 3-4 sentences: Workflows are structured, multi-session feature development tracked through five phases. They solve the problem of losing context across sessions by using handoff prompts, checkpoints, and beads issue tracking. Each phase produces artifacts that feed the next.

#### Section 2: The five phases

One paragraph per phase:

| Phase | Purpose | Produces |
|-------|---------|----------|
| Research | Find unknowns, map the problem space, document findings and dead ends | Research notes, index, dead-ends log |
| Plan | Synthesize research into architecture — components, patterns, data model | `architecture.md` |
| Spec | Write detailed implementation contracts per component | Numbered spec files (`01-*.md`, `02-*.md`) |
| Decompose | Analyze dependencies, schedule parallel work, generate execution docs | Stream documents, beads issues |
| Implement | Execute streams, close issues, verify against acceptance criteria | Working code, closed issues |

#### Section 3: Key artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| State file | `.workflows/<name>/state.json` | Source of truth for phase progress |
| Research index | `.workflows/<name>/research/index.md` | Map of all research findings |
| Dead ends | `.workflows/<name>/research/dead-ends.md` | Failed approaches and learnings |
| Handoff prompts | `.workflows/<name>/<phase>/handoff-prompt.md` | Bridge between phases — current session writes instructions for next |
| Checkpoints | `.workflows/<name>/<phase>/checkpoints/*.md` | Mid-session progress snapshots with resumption prompts |
| Architecture doc | `docs/feature/<name>/architecture.md` | Design blueprint from plan phase |
| Spec files | `docs/feature/<name>/NN-*.md` | Implementation contracts from spec phase |
| Stream docs | `.workflows/<name>/streams/` | Self-contained execution documents from decompose phase |

#### Section 4: Handoff prompts

Explain: Handoff prompts are the core meta-prompt mechanism. The current session (with deep context from doing the work) writes instructions for the next session (starting cold). They live at `.workflows/<name>/<phase>/handoff-prompt.md` and are read by the next phase's entry command.

#### Section 5: Command quick-reference

| Situation | Command |
|-----------|---------|
| Start a new feature workflow | `/workflow-start <name>` |
| Begin or continue a phase | `/workflow-research`, `/workflow-plan`, `/workflow-spec`, `/workflow-decompose`, `/workflow-implement` |
| Check progress | `/workflow-status <name>` |
| Get guidance on what to do next | `/workflow-help <name>` |
| Save mid-session progress | `/workflow-checkpoint` |
| Complete a phase and advance | `/workflow-checkpoint --phase-end` |
| Resume after a break | `/workflow-reground <name>` |
| Abandon current direction | `/workflow-redirect <name>` |
| Archive completed workflow | `/workflow-archive <name>` |
| Improve the harness itself | `/workflow-meta <description>` |

#### Section 6: Getting started

```
1. /workflow-start my-feature
2. /workflow-research my-feature
3. (research topics, write notes)
4. /workflow-checkpoint --phase-end
5. /workflow-plan my-feature
6. (repeat for each phase)
```

### 5. Write the Process section — Mode B (with name)

When invoked with a workflow name, follow these steps:

**Step 1: Read state**

Read `.workflows/<name>/state.json`. Extract `current_phase` and each phase's `status`. If the file doesn't exist, report "No workflow named `<name>` found. Run `/workflow-start <name>` to create one."

**Step 2: Read context files**

Based on `current_phase`, read the relevant handoff prompt and latest checkpoint:

| Current Phase | Handoff to Read | Why |
|---------------|----------------|-----|
| research | (none — first phase) | — |
| plan | `.workflows/<name>/research/handoff-prompt.md` | What research found |
| spec | `.workflows/<name>/plan/handoff-prompt.md` | Architecture decisions |
| decompose | `.workflows/<name>/specs/handoff-prompt.md` | Spec summary |
| implement | `.workflows/<name>/streams/handoff-prompt.md` | Work breakdown |

Also read the latest checkpoint file from `.workflows/<name>/<current-phase>/checkpoints/` if any exist (most recent by filename).

**Step 3: Generate narrative guidance**

Output a narrative summary:

1. **Where you are**: "You're in the **`<phase>`** phase of `<name>`."
2. **What came before**: One-sentence summary from the handoff prompt (if exists). E.g., "The research phase found three key design decisions documented in the handoff."
3. **What to do next**: Phase-specific actionable guidance:

| Phase Status | Guidance |
|-------------|----------|
| `not_started` | "This phase hasn't started. Run `/workflow-<phase> <name>` to begin." |
| `active` (no checkpoint) | "This phase is active but has no checkpoint. Run `/workflow-<phase> <name>` to continue, or `/workflow-checkpoint` to save progress." |
| `active` (has checkpoint) | "Last checkpoint: `<date>`. Resume with `/workflow-reground <name>` to reload context, then `/workflow-<phase> <name>` to continue." |
| `completed` | "This phase is complete. Next: `/workflow-<next-phase> <name>`." |

4. **Key files to read now**: List the 3 most relevant files for the current phase:

| Phase | Files |
|-------|-------|
| research | `research/index.md`, `research/dead-ends.md`, latest checkpoint |
| plan | `research/handoff-prompt.md`, `architecture.md`, latest checkpoint |
| spec | `plan/handoff-prompt.md`, `architecture.md`, spec index |
| decompose | `specs/handoff-prompt.md`, spec files, stream docs |
| implement | streams handoff, `bd ready` output, stream docs |

5. **For more detail**: "Run `/workflow-status <name>` for phase progress table and artifact counts."

### 6. Write the Key principles section

```markdown
## Key principles

- **Read-only.** This command never modifies state.json, beads issues, or any files.
- **Education, not data.** No-args mode teaches the harness concepts. For status data (artifact counts, session timestamps), use `/workflow-status`.
- **Guidance, not context loading.** With-name mode points to what to do next. For full context recovery (loading all phase artifacts), use `/workflow-reground`.
- **Defer to specialists.** Each existing command owns its domain — this command is the "which command should I run?" entry point.
```

## Acceptance Criteria

- [ ] File exists at `home/.claude/commands/workflow-help.md` with correct frontmatter (`description`, `user_invocable: true`)
- [ ] `/workflow-help` (no args) outputs educational content covering all five phases, key artifacts, handoff prompt explanation, and command quick-reference
- [ ] `/workflow-help <name>` reads state.json and handoff prompt, generates narrative guidance with "where you are", "what to do next", and "key files to read"
- [ ] `/workflow-help <name>` for a nonexistent workflow reports the error and suggests `/workflow-start`
- [ ] No status data duplication — does not output phase tables, artifact counts, or session timestamps (owned by `/workflow-status`)
- [ ] Command is discoverable via Claude Code's automatic command detection
