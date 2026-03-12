# Handoff: decompose → implement

## What This Phase Produced
- Phase work items at `docs/feature/serena-usage/phase-1-foundation.md` and `phase-2-wiring.md`
- Concurrency map at `docs/feature/serena-usage/phase-1/streams.md`
- Stream execution docs:
  - `docs/feature/serena-usage/phase-1/stream-a-serena-ensure.md`
  - `docs/feature/serena-usage/phase-1/stream-b-skill.md`
  - `docs/feature/serena-usage/phase-2/stream-c-wiring.md`
- Issue manifest at `.workflows/serena-usage/issues/manifest.jsonl`
- 4 beads issues created and linked with dependencies

## Implementation Order

1. **Phase 1 — Foundation** (parallel):
   - Stream A: `dotfiles-ma8` — Modify `bin/serena-ensure` (M)
   - Stream B: `dotfiles-b7o` — Create skill file (M)
2. **Phase 2 — Wiring** (sequential, after Phase 1):
   - Stream C: `dotfiles-yhm` + `dotfiles-m65` — Hook update + CLAUDE.md (S+S)

## Stream Summary

| Stream | Title | Issues | Scope | Depends On |
|--------|-------|--------|-------|-----------|
| A | serena-ensure Auto-Detection | dotfiles-ma8 | M | -- |
| B | Serena Activate Skill | dotfiles-b7o | M | -- |
| C | Wiring | dotfiles-yhm, dotfiles-m65 | S | A, B |

## Critical Path
Stream A or B (M) → Stream C (S) = **M + S**

## Instructions for Implement Phase

1. Run `bd ready` to find unblocked work — W-01 and W-02 are immediately available
2. For Phase 1 parallel work: launch two worktree sessions (Stream A and Stream B) or implement sequentially
3. Each stream doc contains a self-contained Implementation Prompt at the bottom
4. After Phase 1 completes, W-03 and W-04 become unblocked
5. Implement Stream C (W-03 then W-04)
6. Final validation: start a fresh Claude Code session and verify the full flow:
   - Hook outputs activation context
   - Claude invokes `/serena-activate`
   - Serena tools get called
   - Dashboard shows tool usage stats

## Files to Read First
1. `docs/feature/serena-usage/phase-1/stream-a-serena-ensure.md` (or stream-b-skill.md)
2. The spec referenced by the stream doc
3. The existing code file being modified
