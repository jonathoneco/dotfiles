# Handoff: spec → decompose

## What This Phase Produced
- Two implementation specs, both independent single-file deliverables
- Spec index with dependency information
- No cross-cutting contracts (components share no interfaces or state)

## Key Artifacts
| File | Purpose |
|------|---------|
| `docs/feature/workflow-harness-iteration/01-workflow-help.md` | Full spec for workflow-help command |
| `docs/feature/workflow-harness-iteration/02-workflow-meta.md` | Full spec for workflow-meta skill |
| `.workflows/workflow-harness-iteration/specs/index.md` | Spec index with status |

## Decisions Made
- No cross-cutting contracts needed — components are fully independent
- Specs are detailed enough to implement directly as the final .md files
- workflow-help escalation threshold not applicable (read-only command)
- workflow-meta escalation threshold: 5+ files → recommend /workflow-start

## Open Questions Carried Forward
- None

## Instructions for Next Phase (decompose)
This is a simple decomposition — two independent, single-file implementations with no dependencies between them.

1. Read both specs from `docs/feature/workflow-harness-iteration/`
2. Create two beads issues (one per spec), both unblocked:
   - `[Harness] Implement workflow-help command` — references 01-workflow-help.md
   - `[Harness] Implement workflow-meta skill` — references 02-workflow-meta.md
3. No phasing needed — both can be implemented in parallel
4. No stream execution documents needed — each spec is already self-contained
5. The decompose phase can be very short given the simplicity

## Files to Read First
1. `.workflows/workflow-harness-iteration/specs/index.md`
2. `docs/feature/workflow-harness-iteration/01-workflow-help.md`
3. `docs/feature/workflow-harness-iteration/02-workflow-meta.md`
