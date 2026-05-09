---
name: to-plan
description: Write the strawman PLAN.md for a fresh arch worktree from a vacuum frame — design from operational pressure on what's currently in main, not as synthesis of prior exploration. Use when starting a new arch/* worktree, when the user says "write a PLAN.md for this work" or "draft the plan", or before /grill-me runs against a new design. Sister to /to-prd (which produces the PRD from the grilled plan), /to-issues, /to-pr, /from-pr.
---

# To Plan

You are drafting the vacuum-framed strawman `PLAN.md` for a fresh `arch/<slug>` worktree — the position `/grill-me` will interrogate and `/to-prd` will later compile.

Refuse if the branch isn't `arch/<slug>`, the working tree is dirty, `PLAN.md` already exists, or the chain scaffold carries synthesis artifacts copied in. If the operational pain can't be stated in three concrete sentences against today's modules, surface that to the user instead of drafting.

## Vacuum-frame, don't synthesize

You will often have prior exploration in context — multi-agent runs, superseded designs, abandoned PRDs. Synthesis posture leaks that history forward: "the synthesis chose…", "rejecting D4's framing because…", "five designs converged on…". The PLAN.md becomes a transcript of past thinking, and the grill burns its rounds re-litigating prior runs instead of pushing on real architectural choices.

Vacuum-framing is the opposite stance: write as if the architect just walked into the codebase, looked at existing modules and ADRs, and identified the operational pain. The discipline is load-bearing — see [`VACUUM-FRAME.md`](./VACUUM-FRAME.md).

## Coverage

Every operational pressure point in `main` where the topic lands is named in `## Why this exists`. Three concrete sentences against today's modules. If you can't state the pain that way, you don't have a PLAN.md yet — surface to the user.

## When to invoke

- Starting a fresh `arch/<slug>` worktree for non-trivial design work.
- The user says "write a PLAN.md for this", "draft the plan", "kick off the worktree".
- Before `/grill-me` runs — the PLAN.md is the strawman the grill pushes against.

## When NOT to invoke

- Implementation worktrees not doing architectural work — those go straight to the PRD from `/to-prd`.
- Continuing an existing arch worktree's PLAN.md — read what's there and edit, don't restart.
- Writing a PRD — that's `/to-prd`, runs against a _grilled_ PLAN.md.
- Writing implementation issues — that's `/to-issues`, runs against a PRD.

## Process

1. Verify the worktree. Branch is `arch/<slug>` and fresh; `PLAN.md` does not already exist; the chain scaffold is clean; no synthesis artifacts copied in. If any check fails, surface it.
2. Identify the operational pain against `main` — existing modules, cost shape that doesn't generalize, new requirements on the horizon. This grounds `## Why this exists`.
3. Name the central abstraction — the seam that justifies the layer, the type signature that becomes the test surface. Without this, the PLAN.md is just a glossary.
4. Map existing modules onto the new contract. Do not invent new module names unless the design requires them.
5. Draft sections in order against [`PLAN-TEMPLATE.md`](./PLAN-TEMPLATE.md) — section ordering lives in [`PLAN-SHAPE.md`](./PLAN-SHAPE.md), voice rules in [`VOICE-RULES.md`](./VOICE-RULES.md). Top to bottom; later sections depend on earlier ones being named.
6. Sanity-check against [`VACUUM-FRAME.md`](./VACUUM-FRAME.md) — strip prior-arch references, synthesis vocabulary, rejection lists, numbered binary lists, pre-resolution leakage, invented entity renames.
7. Length check. Target 250–400 lines. Over → push features into `Door-open, not built today`. Under → operational invariants are too thin.
8. Save and stop. Write to worktree root as `PLAN.md`. Untracked is the convention; `/from-pr` deletes it at merge. Do NOT run `/grill-me` automatically — the user drives that as a separate move.

## Output

Structured Markdown at the worktree root, sections per [`PLAN-SHAPE.md`](./PLAN-SHAPE.md), voice per [`VOICE-RULES.md`](./VOICE-RULES.md), starting structure per [`PLAN-TEMPLATE.md`](./PLAN-TEMPLATE.md).

## Don't

- Interview the user. Distillers synthesize from context. If interrogation is needed, the wrong shape is loaded — call `/grill-me` first.
- Synthesize from prior exploration. Vacuum-framing is the load-bearing discipline ([`VACUUM-FRAME.md`](./VACUUM-FRAME.md)).
- Reference prior arch worktrees by name — even ones that landed.
- Number open binaries. Prose is mandatory in `## Open architectural questions`; the numbered binary list is a _grilling output format_, not a strawman input.
- Pre-resolve open questions in `## V1 scope`. If a binary is genuinely live, the V1 section commits to it; if it's not, don't pretend it is.
- Write a "What this replaces" section that names dissolving entities. Today's awkward shape is for the architect+human to discover during grilling.
- Run `/grill-me` automatically. Save the PLAN.md and stop.
- Produce a PRD. That's `/to-prd`, runs _after_ grilling.

## When something goes wrong

- 9-agent synthesis output and you don't know what to keep → strip to architectural skeleton (load-bearing primitives, central abstraction, layer split). Re-write `## Why this exists` against today's main. Drop provenance, numbered binaries, hybrid-framing rationale, rejection lists.
- Pain isn't operational, it's aesthetic → if `## Why this exists` reads "current code is ugly" rather than "cost shape doesn't generalize", surface to the user. Aesthetic refactors don't earn an arch worktree.
- User asks for a PRD instead → decline and route. PLAN.md → `/grill-me` → `/to-prd` → PRD in the chain scaffold. Skipping the grill produces a PRD with the hedge-or-pre-resolve smell vacuum-framing exists to prevent.
