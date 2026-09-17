---
name: blueprint
description: Write one unit of work (a ticket, an issue, a task brief) with implementation details exact enough that the implementer builds what was decided, without guessing or reopening it. Use when Jon says blueprint or asks for a ticket to be implementation-ready.
---

# Blueprint

The bar: every implementation detail in the unit is exact and verified, so the implementer builds what was decided. A paraphrase of a shape is a guess the implementer has to resolve; the shape itself is not.

## Fidelity

- Every type, schema, signature, table, event, and identifier the work touches appears verbatim, as a code snippet, not described in prose.
- Every file and symbol is named exactly as it exists on `main` at the time of writing, checked by reading it. Line numbers are never cited.
- Every settled decision the work depends on is restated in the unit, marked as decided, with its source. When there is no spec or design page, the source is the conversation or the investigation that settled it, and the unit is the record: it states the decision and the reason, so nothing has to be reconstructed from the transcript. An undecided point is settled before the unit is written; it is asked, not carried.
- Every step names the file and symbol it changes and what the change is. "Update the handler" is not a step; "in `convex/needs/evaluate.ts`, `evaluateNeed` returns `NeedVerdict` instead of `boolean`, shape below" is.
- Verification names the test boundary and the exact cases or scenario numbers, so passing them is the definition of done.

## Contents, in order

- Title: the deliverable.
- Read-first: the spec or design pages it depends on, when they exist.
- Decisions: each settled decision, one sentence, with source, not open for redesign.
- Shapes: the code the unit must produce or consume, as snippets.
- Surface: exclusive paths this unit alone changes; shared paths where it touches only its own keys.
- Steps: ordered; file, symbol, change.
- Verification: test boundary and cases.
- Done: checkable boxes, no judgment needed to tick them.
- Out of scope: what a reader would assume is included and is not.
- Blockers: units that land first.

A defect unit carries observed behavior, a reproduction against current `main` or production, and evidence with its date and SHA. The fix is its own decision unless the fix is what is being ratified.

## Bound

One coherent behavior, one domain, one sitting. A unit that spans two of any of these is split, with the dependency noted.

## Check

Read the unit as the implementer, with only the repo and the unit. Every place you would guess, look outside, or reopen a decision is a defect in the unit; fix it in place. An open question that must stay names the later work that owns it. Text left from an earlier draft that no longer holds is removed.

## Tracker

The project's tracker doc sets fields, labels, estimate, and milestone; set them all. For a set of units, `to-tickets` handles the blocking edges and publication; this skill is one unit's content.
