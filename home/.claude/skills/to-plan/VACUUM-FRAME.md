# Vacuum frame discipline

The load-bearing principle behind `/to-plan`: **the PLAN.md describes the design as if the architect just walked into the codebase**, looked at the existing modules and ADRs and product spec, identified an operational pain point, and wrote a design doc.

This is a discipline of stance, not omission. The author often _has_ prior exploration in context — multi-agent runs, superseded designs, abandoned PRDs. Vacuum-framing means the output PLAN.md does not carry that context forward. The design stands on its operational merits or it doesn't stand at all.

## Synthesis vs vacuum-framing

| Synthesis posture (wrong) | Vacuum-framing posture (right) |
|---|---|
| "Five designs converged on the engine pattern…" | "The engine is the consolidation point." |
| "Rejecting D4's outbound-as-flag framing because…" | (no rejection list at all) |
| "This refines the prior arch/plan-chain candidate." | "Today's `convex/email/dispatch.ts` does X; the new layer absorbs Y." |
| "The synthesis chose option B over option A." | (commits to B; doesn't enumerate A) |

Synthesis attribution leaks weak prior commitments into the strawman, smuggles unresolved tradeoffs into language the grill can't easily push on, and trains the next reader to treat the PLAN.md as a transcript of past thinking instead of a position to interrogate.

## What vacuum-framing forbids

The PLAN.md contains **no references to**:

- Prior arch worktrees by name (`arch/plan-chain`, etc.) — even superseded ones.
- Prior multi-agent runs ("the synthesis chose…", "five designs converged on…", "critique-2 caught…").
- Prior PLAN.md drafts the design evolved out of.
- Prior PRDs that got abandoned.
- "Designs we considered" — the design stands on its own.

It also contains **no rejection lists**:

- Don't write "This rejects X from Y design" sections.
- Don't write "Anti-patterns we avoided" framed as rejection of prior alternatives.
- Don't write "Naming churn rejected" sections — just _use_ the operational names without explaining why.

## What is fair game

References checked into `main` are operational, not historical:

- ADR numbers (because they live in `docs/architecture/adr/`).
- Existing module paths (`convex/flags.ts`, `convex/email/dispatch.ts`).
- Existing schema entries (`flags` table, `apiCalls` table).
- Product principles in `CLAUDE.md`, `CONTEXT.md`, `DESIGN.md`.
- Operational vocabulary in active production code.

**The slogan:** _the architect just walked into the codebase._ Everything you'd reference under that frame is fair game; everything you wouldn't isn't.

## Why this discipline is load-bearing

The PLAN.md is the strawman `/grill-me` interrogates. A grill against a synthesis-attributed PLAN.md spends its rounds re-litigating prior runs instead of pushing on real architectural choices. A grill against a vacuum-framed PLAN.md spends its rounds where it should: on the operational tradeoffs the design hasn't yet pinned. Vacuum-framing buys grilling its full bandwidth.
