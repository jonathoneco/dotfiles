---
name: work-harness
description: "Adaptive work harness conventions — state model, triage, review gates, escalation. Activates when .work/ directory exists with active tasks (state.json where archived_at is null). Propagate to implementation and review subagents via skills: [work-harness] frontmatter."
---

# Work Harness

This skill provides knowledge about the adaptive work harness — the unified
system for managing tasks from one-line fixes to multi-week initiatives.
It exists as a skill so that subagents (implementation agents, review agents,
research agents) inherit harness conventions.

## When This Activates

- `.work/` directory exists with at least one active task
- Running work commands (`/work`, `/work-fix`, `/work-feature`, `/work-deep`)
- Running state commands (`/work-status`, `/work-checkpoint`, etc.)

## References

- **triage-criteria** — 3-factor depth assessment formula and scoring rubric
- **review-methodology** — Review gate process, finding lifecycle, severity enforcement
- **state-conventions** — State model schema, step lifecycle, task discovery
- **depth-escalation** — When and how to escalate from one tier to another

## Path Convention

All generated artifacts (checkpoints, handoff prompts, research notes, findings, specs) MUST use **project-relative paths** — never absolute paths or home directory references.

- **Correct**: `internal/handlers/auth.go`, `.work/task-name/research/notes.md`
- **Wrong**: `/home/user/src/project/internal/handlers/auth.go`, `~/docs/spec.md`

This applies to file listings, findings, spec references, and any path written to `.work/` or `docs/`.

## Key Concepts

- **3 tiers**: Fix (T1), Feature (T2), Initiative (T3)
- **Steps are data**: The `steps` array in state.json defines available phases
- **Auto-detect**: Commands read `current_step` and present the right interface
- **Every task has a beads issue**: Created during the assess step
- **State committed to git**: `.work/` directory is tracked, not gitignored
