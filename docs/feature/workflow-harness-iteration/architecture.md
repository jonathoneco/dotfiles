# Workflow Harness Iteration — Architecture

| Field | Value |
|-------|-------|
| Status | Draft |
| Workflow | workflow-harness-iteration |
| Created | 2026-03-12 |

## Overview

A new command and a new skill for the workflow harness: `/workflow-help` (onboarding and navigation command) and `/workflow-meta` (active skill for iterating on the harness infrastructure itself). They serve different roles — help is a read-only guide, meta is a hands-on methodology for harness improvement work.

## System Context

The workflow harness is a set of markdown command files that Claude Code discovers automatically from `home/.claude/commands/`. Each command is a self-contained prompt template with YAML frontmatter. Commands read/write workflow state from `.workflows/<name>/state.json` and integrate with beads issue tracking.

**Existing command inventory** (13 files in `home/.claude/commands/`):
- Phase lifecycle: `workflow-start`, `workflow-research`, `workflow-plan`, `workflow-spec`, `workflow-decompose`, `workflow-implement`
- Session management: `workflow-checkpoint`, `workflow-reground`
- Observability: `workflow-status`
- Lifecycle: `workflow-archive`, `workflow-redirect`
- Non-workflow: `adversarial-eval`, `ama`

**Gaps**:
- No command explains the harness itself (onboarding/navigation)
- No formalized way to iterate on the harness infrastructure — requires manual priming (e.g., knowing to run `/workflow-start workflow-harness-iteration`)

## Architectural Patterns

**Command** (`workflow-help`) follows the established command template:

```yaml
---
description: "<one-line>"
user_invocable: true
---

# Title

## Arguments
## Process
## Key principles
```

**Skill** (`workflow-meta`) follows the established skill template:

```yaml
---
name: workflow-meta
description: "<one-line>"
---

# /workflow-meta

## Usage
## Workflow
```

Key distinction: commands are point-in-time guidance/orchestration; skills are end-to-end task completion methodologies (like `/add-feature` or `/fix-issue`).

## Component Map

### Component 1: workflow-help

**Purpose**: Onboarding and navigation — explain the harness to new/lost users and point them to the right next action.

**Two modes**:

#### Mode A: No args (`/workflow-help`)

Static educational content embedded directly in the command file. No file reads or dynamic generation needed.

Sections:
1. **What is a workflow?** — 3-4 sentences on why multi-session structured work exists
2. **The five phases** — One paragraph per phase: purpose, input, output
   - Research: Find unknowns, map the problem space
   - Plan: Synthesize into architecture document
   - Spec: Detailed contracts per component
   - Decompose: Schedule parallel work, generate execution docs
   - Implement: Execute streams, close issues
3. **Key artifacts** — Table of file locations and what they contain
4. **Handoff prompts** — What they are, why they exist, where to find them
5. **Command quick-reference** — "When to use which command" table mapping situations to commands
6. **Getting started** — `workflow-start` → `workflow-research` → `workflow-checkpoint --phase-end` → repeat

#### Mode B: With workflow name (`/workflow-help <name>`)

Reads workflow state and handoff prompts to provide contextual guidance. Does NOT replicate `/workflow-status` output — instead directs the user there for data.

Process:
1. Read `.workflows/<name>/state.json` — extract `current_phase` and phase statuses
2. Read the current phase's handoff prompt (from the previous phase) if it exists
3. Read the latest checkpoint file if one exists for the active phase
4. Generate narrative guidance:
   - "You're in the **plan** phase of `<name>`."
   - "The research phase found: `<handoff summary>`"
   - "Your next step: Run `/workflow-plan <name>` to continue, or `/workflow-status <name>` for detailed progress."
5. List the 3 most relevant files to read right now (phase-dependent)
6. Show which commands are relevant for the current phase

**What it does NOT do** (owned by `/workflow-status`):
- Phase progress table with artifact counts
- Session counts and timestamps
- Beads epic status

**Relationship to other commands**:

| Situation | Command |
|-----------|---------|
| "What is this workflow system?" | `/workflow-help` |
| "Where am I in workflow X?" | `/workflow-help <name>` |
| "Show me the data for workflow X" | `/workflow-status <name>` |
| "Load context so I can resume work" | `/workflow-reground <name>` |

### Component 2: workflow-meta

**Type**: Skill (`home/.claude/skills/workflow-meta/SKILL.md`)

**Purpose**: Active skill for iterating on the workflow harness infrastructure. This is the formalized entry point for "I want to improve the workflow system itself" — the same kind of work this current session is doing, but without requiring manual bootstrapping.

**Analogy**: `/add-feature` is to application code as `/workflow-meta` is to the harness. Both are end-to-end methodologies that create issues, gather context, implement changes, and verify results.

**Invocation**: `/workflow-meta <description of what to improve>`

#### Workflow steps

1. **Load harness inventory** — Scan all harness files in parallel:
   - `home/.claude/commands/workflow-*.md` — all workflow commands
   - `home/.claude/skills/*/SKILL.md` — all skills
   - `home/.claude/agents/*.md` — all agents
   - `.workflows/*/state.json` — active workflow health
   - Summarize: "Found N commands, N skills, N agents, N active workflows"

2. **Validate harness health** — Quick consistency checks before making changes:
   - Command frontmatter: every `workflow-*.md` has `description` + `user_invocable: true`
   - Workflow state integrity: valid phase structure, ISO 8601 timestamps
   - Beads consistency: epic/gate IDs resolve to actual issues
   - Artifact completeness: completed phases have handoff prompts and checkpoints
   - Report any issues found before proceeding

3. **Search for prior art** — Check beads issues and git history for related past work:
   - `bd search '<keywords>'` for relevant closed issues
   - Search dead-ends across workflows to avoid repeating failed approaches

4. **Break down the improvement** — Create beads issues for each change:
   - Tag issues with `harness` label
   - Set dependencies (e.g., new command depends on updated shared patterns)
   - Claim the first unblocked issue

5. **Implement changes** — Work through issues sequentially:
   - Edit/create command, skill, or agent files
   - Follow established templates (command frontmatter, skill structure)
   - For each change, validate: read the modified file back, check frontmatter, confirm structure

6. **Verify** — After all changes:
   - Run `./validate.sh` to catch any regressions
   - Read back each modified file to confirm correctness
   - Close all beads issues

**Self-referential safeguard**: If the user asks to modify `workflow-meta` itself via `/workflow-meta`, the skill should acknowledge the recursion, proceed carefully, and suggest a manual review of the changes before committing.

**Key difference from `/workflow-start`**: workflow-meta is a single-session skill for targeted harness improvements. For large, multi-session harness overhauls, it should recommend using the full workflow system (`/workflow-start workflow-<name>`) instead — which is exactly what this current session demonstrates.

## Interaction Map

```
User Journey A: "I'm new to workflows"
  /workflow-help
    → Reads educational content (phases, artifacts, commands)
    → Points to /workflow-start <name>

User Journey B: "I'm lost in an active workflow"
  /workflow-help <name>
    → Reads state + handoff for narrative guidance
    → Points to /workflow-status <name> for data
    → Points to /workflow-<phase> <name> to continue

User Journey C: "I want to make a quick improvement to the harness"
  /workflow-meta <description>
    → Loads harness inventory, validates health
    → Creates issues, implements changes in a single session
    → Verifies with validate.sh

User Journey D: "I want a major harness overhaul"
  /workflow-start workflow-<name>
    → Full multi-session workflow (research → plan → spec → implement)
    → This is what the current session demonstrates
```

## Phasing Summary

Both are independent — no dependency between them. Implementation order doesn't matter.

| Phase | Work | Location |
|-------|------|----------|
| 1 | `workflow-help` — command: static educational content + dynamic workflow guidance | `home/.claude/commands/workflow-help.md` |
| 2 | `workflow-meta` — skill: active harness improvement methodology | `home/.claude/skills/workflow-meta/SKILL.md` |

No changes to existing commands or skills required.

## Open Questions

- Should `/workflow-help` detect the absence of any workflows and skip the "with name" mode guidance entirely?
- What's the size threshold where `/workflow-meta` should recommend escalating to a full `/workflow-start` workflow instead of handling inline?
