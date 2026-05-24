---
name: improve-codebase-architecture
description: Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and the decisions in docs/adr/. Use when the user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more testable and AI-navigable.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is _informed_ by the project's domain model. The domain language gives names to good seams; ADRs record decisions the skill should not re-litigate.

## Process

### 1. Explore

Read the project's domain glossary and any ADRs in the area you're touching first.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates

Present a numbered list of deepening opportunities. For each candidate:

- **Files** — which files/modules are involved
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and also in how tests would improve

**Use CONTEXT.md vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If `CONTEXT.md` defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly (e.g. _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline as decisions crystallize:

- **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the term to `CONTEXT.md` — same discipline as `/grill-with-docs` (see [CONTEXT-FORMAT.md](../grill-with-docs/CONTEXT-FORMAT.md)). Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `CONTEXT.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones. See [ADR-FORMAT.md](../grill-with-docs/ADR-FORMAT.md).
- **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

## Migration debris audit methodology

A specialised sub-mode of the deepening sweep: surfacing **migration debris** — code that was load-bearing during a prior migration but got replaced and never deleted. Use this when the user wants a debris-cleanup pass rather than a deepening pass, or when the deepening sweep keeps tripping over dead code that obscures the live shape.

The point of the methodology is _classifying candidates by confidence_ so the cleanup PR carries deterministic blast radius. Mis-classification is expensive in both directions — deleting a load-bearing helper breaks prod silently; leaving accumulated debris compounds every future reader's cost of understanding the live shape.

### Confidence buckets

- **HIGH** — zero production callers _and_ clear evidence of replacement. Signals: throw-only handler bodies (`throw new Error("retired…")`), unregistered generators (exported but not present in a registry like `PROPOSAL_GENERATORS`), comment markers like `retired` / `@deprecated` / `no longer used` / `kept for backwards compat` / `safe to delete` / `migration artifact`, schema fields marked `// DEPRECATED`, helpers whose only callers are other dead helpers. Safe to delete in a focused PR.
- **MEDIUM** — likely dead but the replacement isn't obvious, _or_ there's one suspicious caller worth re-reading. Surface for per-item disposition review; don't bundle into the same PR as HIGH.
- **LOW** — looks suspicious (TODO with a past date, unusual shape) but uncertain. Surface in a findings list, not for deletion.

### Mechanical signals to grep for

```sh
grep -rn "retired\|@deprecated\|DEPRECATED\|TODO: delete\|TODO: remove\|legacy fallback\|no longer used\|kept for backwards compat\|backwards compat\|safe to delete\|migration artifact" convex/ src/
```

Plus structural signals (each one earns a candidate row):

- Throwing-only handler bodies — body is `throw new Error("retired…")` or equivalent.
- Files exporting a generator NOT present in its registry (e.g. `PROPOSAL_GENERATORS`).
- Exported functions whose only callers are test files — `grep` for the symbol and filter out `*.test.ts` / `*.spec.ts`; zero non-test callers = HIGH candidate.
- Schema fields with `// DEPRECATED` comments at their definition.
- ADRs marked `Status: Superseded` — check whether the code they introduced has actually been cleaned up, or whether the supersession was decision-only.

### Output

A three-bucket list. HIGH ships as a focused cleanup PR (each candidate names file + symbol + evidence + line count it deletes). MEDIUM ships as a gated review list (user picks per-item). LOW ships as a findings list with no action recommended.

The 2026-05-17 cleanup-grill arc is the canonical worked example: ~1,500 HIGH-confidence lines + ~280 MEDIUM gated, shipped across 15+ focused PRs (commits `f702caa8` through `d9a48553`). Closed a backlog of accumulated debris from the `recordObservation` / engine / outbounds-override migrations.

This methodology is the companion to the CLAUDE.md "Work owns its own migration" guardrail. When migrations are well-disciplined, this sweep surfaces little. When debris accumulates, this is the recovery pass.
