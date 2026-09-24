---
name: blueprint
description: Blueprint one unit of work so the implementer builds what was decided, without guessing or reopening it. Use when Jon says blueprint or asks for a ticket to be implementation-ready.
---

# Blueprint

The bar: every implementation detail in the unit is exact and verified, so the implementer builds what was decided. A paraphrase of a shape is a guess the implementer has to resolve; the shape itself is not.

Start by reading every file the unit touches, where the implementer will find it. The unit is written from that reading, not from memory, the tracker, or an earlier draft.

## Self-contained

The unit carries everything its implementer needs. It points only at what the implementer can open: the repo by path and symbol, other units by tracker key with the one fact this unit uses from each stated inline, and public URLs. Decisions, constraints shared across the project (rollout flags, test recipients, review loop) and anything learned in private notes or the conversation are written into the unit itself.

## Fidelity

- What the unit produces or changes appears verbatim, as a code snippet: a new or changed type, schema, signature, table, event payload, identifier. What it only reads is cited by file path and workspace symbol; the implementer opens it. Name the ref when it is not `main`. Point with symbols; line numbers drift before the unit is picked up.
- Every quote is exact and findable. Every link resolves; open it before the unit ships.
- Every decision the work depends on is settled now, by asking, and stated in the unit as decided: the decision, the reason, who decided and when.
- Every step names the file and symbol it changes and what the change is. "Update the handler" is not a step; "in `convex/needs/evaluate.ts`, `evaluateNeed` returns `NeedVerdict` instead of `boolean`, shape below" is.
- Words a user reads (labels, errors, confirmations) are in the user's own language and match the strings already on that screen. List them in a table: where, what the user reads, the existing string it matches.
- Verification names the test boundary and the exact cases or scenario numbers, so passing them is the definition of done.

## Contents, in order

- Title: the deliverable.
- Outcome: what the user sees today and after.
- Decided: each settled decision with its reason, who and when; not open for redesign.
- Steps: ordered; file, symbol, change, each ending on a checkable condition.
- Verification: test boundary and cases.
- Done: checkable boxes, no judgment needed to tick them.
- Out of scope: what a reader would assume is included and is not.
- Blockers: units that land first.
- Shapes and surface: the code the unit produces or changes, as snippets; exclusive paths this unit alone changes, shared paths where it touches only its own keys.

A defect unit carries observed behavior, a reproduction against current `main` or production, and evidence with its date and SHA. The fix is its own decision unless the fix is what is being ratified.

## Bound

One coherent behavior, one domain, one sitting. A unit that spans two of any of these is split, with the dependency noted.

## Check

Run `/writing-for-agents` over the unit; its reader is an implementer, often at low effort. Then read the unit as that implementer, with only the repo and the unit. Every place you would guess, look outside, or reopen a decision is a defect in the unit; fix it in place, asking whatever it takes to settle it now. Text left from an earlier draft that no longer holds is removed, and the tests agree with the decisions they prove.

## Tracker

The project's tracker doc sets fields, labels, estimate, and milestone; set them all. For a set of units, `to-tickets` handles the blocking edges and publication; this skill is one unit's content.
