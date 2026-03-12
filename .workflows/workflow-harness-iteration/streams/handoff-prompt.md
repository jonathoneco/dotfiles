# Handoff: decompose → implement

## What This Phase Produced
- Two beads issues, both unblocked and implementable in parallel
- Issue manifest at `.workflows/workflow-harness-iteration/issues/manifest.jsonl`
- No phase docs or stream execution docs needed — specs are already self-contained

## Implementation Order

Single phase, two parallel streams:

```
Phase 1:  [stream-1: workflow-help]  [stream-2: workflow-meta]
          (fully parallel, no dependencies)
```

## Stream Summary
| Stream | Title | Beads Issue | Spec | Scope |
|--------|-------|-------------|------|-------|
| 1 | workflow-help command | dotfiles-hq3 | 01-workflow-help.md | S |
| 2 | workflow-meta skill | dotfiles-sp6 | 02-workflow-meta.md | S |

## Critical Path
Either stream alone — scope S (~few hours). No serial dependencies.

## Instructions for Implement Phase
1. Run `bd ready` to see both unblocked issues
2. Both can be implemented in parallel (e.g., two worktree agents) or sequentially
3. For each issue:
   - `bd update <id> --status=in_progress`
   - Read the corresponding spec: `docs/feature/workflow-harness-iteration/01-workflow-help.md` or `02-workflow-meta.md`
   - Create the file per the spec's Implementation Steps
   - Verify against the spec's Acceptance Criteria
   - `bd close <id>`
4. After both are closed, run `./validate.sh` to confirm no regressions
5. Close gate issues from prior phases

## Files to Read First
1. `docs/feature/workflow-harness-iteration/01-workflow-help.md` (spec for stream 1)
2. `docs/feature/workflow-harness-iteration/02-workflow-meta.md` (spec for stream 2)
3. `.workflows/workflow-harness-iteration/issues/manifest.jsonl` (issue mapping)
