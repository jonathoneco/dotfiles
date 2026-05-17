# PLAN.md voice rules

The PLAN.md voice is imperative, operational, and unhedged. The strawman is a position the grill pushes against, not a survey of possibilities.

## Imperative description, no hedging

```
Good:  "The engine is the consolidation point."
Bad:   "The engine acts as a kind of consolidation point in this design."
```

## Operational vocabulary, never invented synonyms

```
Good:  "Flag, Outbound, Artifact"
Bad:   "Concern, Outreach, Filing" (renames imported from prior exploration)
```

If existing code uses a name, the PLAN.md uses that name. The layer label ("Decision") and the entity names (Flag, Outbound, Artifact) don't have to match — the layer label is the _category_, the entity names are the _kinds_.

## Bold load-bearing terms; reuse as nouns

```
Good:  "**Facts** carry citations natively. … Fact rows never get rewritten."
Bad:   "Facts carry citations. Notes never get rewritten."
       (paraphrased — the term is now ambiguous)
```

## Reference checked-in artifacts only

```
Good:  "extending the pattern ADR 0001 established for `flags`"
Good:  "matches the existing `email/dispatch.ts` pattern"
Bad:   "as proposed in the prior arch/plan-chain candidate"
Bad:   "the synthesis chose this over D4's alternative"
```

## Open questions in prose, not enumeration

```
Good:
  ## Open architectural questions

  **Sweep granularity.** runFileSweep as one fat mutation that
  patches everything atomically, or split into a compute query
  (engine) and an apply mutation (delta dispatch) with an
  expectedHash consistency check between? One-mutation gives
  tighter atomicity and serializability for free; split keeps
  transaction footprint smaller and makes the compute path
  testable in isolation under a Convex harness. The tradeoff
  bites under high-decision-count files.

  These get sharper under V1 implementation pressure.

Bad:
  ## Open binaries

  - B1: Sweep granularity (one mutation vs split): single mutation
    leans …
  - B2: Pre-approval invalidation states: …
  - B3: …
```

## Don't enumerate door-open items without naming the smallest add

```
Bad:   "Cadence is deferred."
Good:  "Cadence lands as a column on Outbound + a rule clause; deferred until the first LO who needs it."
```

A vague "deferred" is a punt; a concrete door-open commits the design to _not_ paint a corner without committing to _build_ the deferred thing.

## Don't import multi-agent run vocabulary

Words to strip during the sanity-check sweep: _synthesis_, _critique lens_, _design 1_, _design 4 + design 5 hybrid_, _converged on_, _rejected_, _hybrid-framing_. None of it appears in the PLAN.md.
