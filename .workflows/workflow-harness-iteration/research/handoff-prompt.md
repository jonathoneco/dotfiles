# Handoff: research → plan

## What This Phase Produced
- Three research notes covering the design of two new workflow commands and their placement
- No dead ends encountered — all approaches validated

## Key Artifacts
| File | Purpose |
|------|---------|
| `.workflows/workflow-harness-iteration/research/index.md` | Research topic map (3 entries) |
| `.workflows/workflow-harness-iteration/research/workflow-help-design.md` | Design analysis for /workflow-help |
| `.workflows/workflow-harness-iteration/research/workflow-meta-design.md` | Design analysis for /workflow-meta |
| `.workflows/workflow-harness-iteration/research/command-vs-skill-placement.md` | Placement decision rationale |

## Decisions Made
- Both workflow-help and workflow-meta are **commands** (not skills) — commands are orchestration/guidance, skills are end-to-end task completion
- workflow-help **complements** /workflow-status (not replaces) — status = data table, help = narrative + guidance
- workflow-help has **two modes**: no args (educational) and with `<workflow>` (directional)
- workflow-meta has **three modes**: status (inventory), validate (consistency), analyze (deep dive)

## Open Questions Carried Forward
- Should /workflow-help internally call /workflow-status logic or reimplement state reading?
- Static vs dynamic educational content in /workflow-help no-args mode?
- Should workflow-meta own harness validation or extend validate.sh?
- Self-referential edge case: workflow-meta suggesting changes to workflow-meta

## Instructions for Next Phase (plan)
Read the three research notes (start with index.md for orientation). Produce an architecture document that covers:

1. **workflow-help command**: Arguments, process steps, output structure for both modes (no-args and with-workflow). Define what state it reads, what it outputs, and how it differs from /workflow-status and /workflow-reground.

2. **workflow-meta command**: Arguments, process steps for each mode (status/validate/analyze). Define what files it scans, what checks it runs, and how it surfaces improvement suggestions.

3. **Shared patterns**: Both commands follow the existing command template (YAML frontmatter with `description` + `user_invocable: true`, markdown body with `## Arguments`, `## Process`, `## Key principles`).

4. **Interaction map**: How these two new commands relate to the existing 11 workflow commands. Show the user journey: "I'm new → /workflow-help" vs "I want to improve the harness → /workflow-meta".

Constraints:
- Follow the exact frontmatter format from existing commands (read any workflow-*.md for reference)
- Both commands should be implementable as single .md files in home/.claude/commands/
- No changes to existing commands unless a clear improvement is identified

## Files to Read First
1. `.workflows/workflow-harness-iteration/research/index.md`
2. `.workflows/workflow-harness-iteration/research/workflow-help-design.md`
3. `.workflows/workflow-harness-iteration/research/workflow-meta-design.md`
4. `.workflows/workflow-harness-iteration/research/command-vs-skill-placement.md`
