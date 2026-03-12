---
description: "Explain the workflow harness and how to use it, or get contextual guidance for a specific workflow."
user_invocable: true
---

# Workflow Help

Explain the workflow harness (no args) or provide contextual "what to do next" guidance for a specific workflow (with name). This command is read-only — it never modifies state.

## Arguments

- `[name]` — optional workflow slug. If provided, loads that workflow's state and generates contextual guidance. If omitted, displays educational content about the harness.

## Process

### Mode A: No arguments — Educational content

If no workflow name is provided, output the following educational content directly. No file reads are needed.

---

#### What is a workflow?

Workflows are structured, multi-session feature development tracked through five phases. They solve the problem of losing context across sessions by using handoff prompts, checkpoints, and beads issue tracking. Each phase produces artifacts that feed the next. A workflow lives in `.workflows/<name>/` and its public docs live in `docs/feature/<name>/`.

#### The five phases

**Research** — Find unknowns, map the problem space, document findings and dead ends. Produces research notes, an index of findings, and a dead-ends log. This is where you explore freely before committing to a direction.

**Plan** — Synthesize research into architecture: components, patterns, data model, and dependency graph. Produces `architecture.md` — the design blueprint that all later phases build on. Decisions made here constrain everything downstream.

**Spec** — Write detailed implementation contracts per component. Produces numbered spec files (`01-*.md`, `02-*.md`, etc.) that define interfaces, acceptance criteria, and edge cases. Each spec is a self-contained contract that an implementer can execute independently.

**Decompose** — Analyze dependencies between specs, schedule parallel work, and generate execution documents. Produces stream documents and beads issues. This phase turns the specs into an actionable work breakdown with clear ordering.

**Implement** — Execute streams, close issues, verify against acceptance criteria. Produces working code and closed issues. Each stream document is self-contained — an implementer can pick one up and execute without reading the entire history.

#### Key artifacts

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

#### Handoff prompts

Handoff prompts are the core meta-prompt mechanism. The current session — which has deep context from doing the work — writes instructions for the next session that will start cold. They live at `.workflows/<name>/<phase>/handoff-prompt.md` and are read by the next phase's entry command. Think of them as a letter from your past self to your future self: what matters, what to watch out for, and what to do first.

#### Command quick-reference

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

#### Getting started

```
1. /workflow-start my-feature
2. /workflow-research my-feature
3. (research topics, write notes)
4. /workflow-checkpoint --phase-end
5. /workflow-plan my-feature
6. (repeat for each phase)
```

---

### Mode B: With workflow name — Contextual guidance

If a workflow name is provided, follow these steps.

#### Step 1: Read state

Read `.workflows/<name>/state.json`. Extract `current_phase` and each phase's `status`.

If the file does not exist, report:

> No workflow named `<name>` found. Run `/workflow-start <name>` to create one.

Then stop — do not proceed to further steps.

#### Step 2: Read context files

Based on `current_phase`, read the relevant handoff prompt:

| Current Phase | Handoff to Read | Why |
|---------------|----------------|-----|
| research | (none — first phase) | — |
| plan | `.workflows/<name>/research/handoff-prompt.md` | What research found |
| spec | `.workflows/<name>/plan/handoff-prompt.md` | Architecture decisions |
| decompose | `.workflows/<name>/specs/handoff-prompt.md` | Spec summary |
| implement | `.workflows/<name>/streams/handoff-prompt.md` | Work breakdown |

Also read the latest checkpoint file from `.workflows/<name>/<current-phase>/checkpoints/` if any exist (most recent by filename).

It is fine if these files do not exist — just note their absence and continue.

#### Step 3: Generate narrative guidance

Output a narrative summary with these sections:

**1. Where you are:** "You're in the **`<phase>`** phase of `<name>`."

**2. What came before:** One-sentence summary from the handoff prompt (if it exists). E.g., "The research phase found three key design decisions documented in the handoff." If no handoff exists (research phase or file missing), say so briefly.

**3. What to do next:** Phase-specific actionable guidance based on status:

| Phase Status | Guidance |
|-------------|----------|
| `not_started` | "This phase hasn't started. Run `/workflow-<phase> <name>` to begin." |
| `active` (no checkpoint) | "This phase is active but has no checkpoint. Run `/workflow-<phase> <name>` to continue, or `/workflow-checkpoint` to save progress." |
| `active` (has checkpoint) | "Last checkpoint: `<date>`. Resume with `/workflow-reground <name>` to reload context, then `/workflow-<phase> <name>` to continue." |
| `completed` | "This phase is complete. Next: `/workflow-<next-phase> <name>`." |

**4. Key files to read now:** List the 3 most relevant files for the current phase:

| Phase | Files |
|-------|-------|
| research | `research/index.md`, `research/dead-ends.md`, latest checkpoint |
| plan | `research/handoff-prompt.md`, `architecture.md`, latest checkpoint |
| spec | `plan/handoff-prompt.md`, `architecture.md`, spec index |
| decompose | `specs/handoff-prompt.md`, spec files, stream docs |
| implement | streams handoff, `bd ready` output, stream docs |

Use full paths relative to `.workflows/<name>/` or `docs/feature/<name>/` as appropriate.

**5. For more detail:** "Run `/workflow-status <name>` for phase progress table and artifact counts."

## Key principles

- **Read-only.** This command never modifies state.json, beads issues, or any files.
- **Education, not data.** No-args mode teaches the harness concepts. For status data (artifact counts, session timestamps), use `/workflow-status`.
- **Guidance, not context loading.** With-name mode points to what to do next. For full context recovery (loading all phase artifacts), use `/workflow-reground`.
- **Defer to specialists.** Each existing command owns its domain — this command is the "which command should I run?" entry point.
