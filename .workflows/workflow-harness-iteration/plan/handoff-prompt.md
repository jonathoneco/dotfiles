# Handoff: plan → spec

## What This Phase Produced
- Architecture document covering both new components with system context, patterns, and interaction map
- Key design decision: workflow-meta is a skill (active methodology), not a command (read-only)

## Key Artifacts
| File | Purpose |
|------|---------|
| `docs/feature/workflow-harness-iteration/architecture.md` | Full architecture with component map, interaction map, phasing |
| `.workflows/workflow-harness-iteration/research/handoff-prompt.md` | Research phase context (decisions, open questions) |

## Decisions Made
- workflow-help is a **command** (`home/.claude/commands/workflow-help.md`) — read-only guidance utility
- workflow-meta is a **skill** (`home/.claude/skills/workflow-meta/SKILL.md`) — active harness improvement methodology
- workflow-help defers all status data to `/workflow-status` — no duplication
- workflow-help has two modes: no-args (static educational) and with-name (dynamic guidance from state + handoffs)
- workflow-meta follows the `/add-feature` pattern: inventory → validate → prior art → issues → implement → verify
- For major overhauls, workflow-meta recommends escalating to `/workflow-start workflow-<name>`

## Open Questions Carried Forward
- Should /workflow-help detect absence of workflows and adjust no-args output?
- Size threshold for /workflow-meta to recommend /workflow-start escalation?

## Instructions for Next Phase (spec)
Read `docs/feature/workflow-harness-iteration/architecture.md` first — the Component Map section defines the two specs needed.

Write two numbered spec files in `docs/feature/workflow-harness-iteration/`:

1. **`01-workflow-help.md`** — Spec for the workflow-help command:
   - Exact YAML frontmatter (description text, user_invocable: true)
   - Full process steps for both modes (no-args and with-name)
   - Static educational content outline (phases, artifacts, command reference)
   - Dynamic guidance logic (which state to read, what narrative to generate per phase)
   - Key principles section
   - Acceptance criteria

2. **`02-workflow-meta.md`** — Spec for the workflow-meta skill:
   - Exact YAML frontmatter (name, description)
   - Full workflow steps (inventory, validate, prior art, issues, implement, verify)
   - What files to scan and what checks to run during validation
   - Self-referential safeguard behavior
   - Escalation threshold guidance
   - Acceptance criteria

Constraints:
- Each spec should be detailed enough to implement directly as the final .md file
- Reference existing commands/skills for template patterns (read any workflow-*.md or SKILL.md)
- No cross-cutting contracts needed — these two components are independent

## Files to Read First
1. `docs/feature/workflow-harness-iteration/architecture.md`
2. `home/.claude/commands/workflow-status.md` (template reference for workflow-help)
3. `home/.claude/skills/add-feature/SKILL.md` (template reference for workflow-meta)
