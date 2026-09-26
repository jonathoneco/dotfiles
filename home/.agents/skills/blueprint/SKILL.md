---
name: blueprint
description: Blueprint an effort into implementation-ready tickets, so each implementer builds what was decided without guessing or reopening it. Use when the user says blueprint, asks for tickets to be implementation-ready, or files or grooms tickets in the tracker.
---

# Blueprint

The bar: every implementation detail in a ticket is exact and verified, so the implementer builds what was decided. A paraphrase of a shape is a guess the implementer has to resolve; the shape itself is not.

A blueprint turns an effort into concrete implementation steps. One ticket or forty, the path is the same; a single ticket just has one cluster and a short grilling round.

## The path

1. **Explore once.** Group the tickets into clusters that share a source or a root cause. For each cluster, one agent reads the sources and writes one exploration note, pinned to the SHA it read, with each claim tagged `[obs]` or `[hyp]`. Every writer in the cluster reads that note instead of the sources. Keep the notes in the effort's folder (the `agent-notes` skill). When the effort's extent is unknown, a cheap survey maps it first. Done when every cluster has its note.
2. **Investigate what can't be ruled yet.** When a cause is unknown, or a decision lacks the facts to rule on, run a read-only investigation first. Its report feeds the ticket's evidence and the ruling; a blueprint starts from a verdict.
3. **Cut the effort into tickets** by the sizing and relationship rules below, each with an estimate.
4. **Write each ticket** to the contents below. Batch writers get the exploration note, one shared brief, and an output file each; they write nothing to the tracker. A decision a writer can't settle from code or production goes in a `## DECISION PENDING` section at the top: the product question, options with what the user sees under each, a recommendation, and a body written assuming it.
5. **Settle every pending decision in one round.** Collect the batch's `DECISION PENDING` sections and run the `grilling` skill once across them. Write each ruling into the ticket's Decided section and remove the pending section. Done when no ticket carries one.
6. **Check once**, before the batch is marked ready (see Check).
7. **File** by [`filing.md`](filing.md), which also covers grooming an existing project.

## Sizing

- One PR per ticket. Related work rides the same PR when it touches the same files.
- Condense by default. One behavior repeated across many files or domains is one ticket, with each place listed as an acceptance check.
- Separate behaviors stay separate tickets; merged tickets broke where they combined them.
- A change too big for one PR becomes a parent with the fewest children that each land alone, never one child per place.
- A writer who finds a ticket can't be one PR stops and brings the evidence (files, independent behaviors, domains). The user decides the split.

## Estimate

An estimate is what the ticket costs to build and land: agent effort, review rounds, and how much risky code it touches. Use the project's scale, or 0/1/2/4/8 when the project documents none, with one sentence saying why. A parent is 0. A ticket that lands above the top of the scale is a parent.

## Relationships and projects

- **Blocks:** B can't start until A lands, because of code or data. Order of preference is not a block.
- **Parent and child:** only for one behavior too big for one PR. The parent states the done condition for the whole.
- **Related:** a pointer, with the one fact this ticket uses from the other written inline.
- **Duplicate:** fold it into the surviving ticket and close it with the duplicate relation.
- **Project:** one per effort with its own outcome that someone tracks. A finding outside that outcome is filed in the project that owns it.
- **Milestone:** only where the project's tracker doc defines milestones.

## Self-contained

The ticket carries everything its implementer needs. It points only at what the implementer can open: the repo by path and symbol, other tickets by tracker key with the one fact used stated inline, and public URLs. Decisions, constraints shared across the project (rollout flags, test recipients, review loop) and anything learned in private notes or the conversation are written into the ticket itself.

## Fidelity

- What the ticket produces or changes appears verbatim, as a code snippet: a new or changed type, schema, signature, table, event payload, identifier. What it only reads is cited by file path and workspace symbol; the implementer opens it. Name the ref when it is not `main`. Point with symbols; line numbers drift before the ticket is picked up.
- Every quote is exact and findable. Every link resolves; open it before the ticket ships.
- Every decision the work depends on is settled and stated as decided: the decision, the reason, who decided and when.
- Every step names the file and symbol it changes and what the change is. "Update the handler" is not a step; "in `convex/needs/evaluate.ts`, `evaluateNeed` returns `NeedVerdict` instead of `boolean`, shape below" is.
- Words a user reads (labels, errors, confirmations) are in the user's own language and match the strings already on that screen. List them in a table: where, what the user reads, the existing string it matches.
- Verification names the test boundary and the exact cases or scenario numbers, so passing them is the definition of done.

## Contents, in order

- Title: the deliverable.
- Outcome: what the user sees today and after.
- Decided: each settled decision with its reason, who and when; not open for redesign.
- Steps: ordered; file, symbol, change, each ending on a checkable condition. The first step re-verifies the ticket against current `main` at lane start.
- Verification: test boundary and cases.
- Done: checkable boxes, no judgment needed to tick them.
- Out of scope: what a reader would assume is included and is not.
- Blockers: tickets that land first.
- Estimate, with its one-sentence reason.
- Shapes and surface: the code the ticket produces or changes, as snippets; exclusive paths this ticket alone changes, shared paths where it touches only its own keys.

A defect ticket carries observed behavior, a reproduction against current `main` or production, and evidence with its date and SHA. The fix is its own decision unless the fix is what is being ratified.

## Check

One pass, by a fresh agent, before any ticket is marked ready. It reads each ticket as the implementer would, with only the repo and the ticket, after running `/writing-for-agents` over it; the implementer often runs at low effort. In the same read it checks the batch as a whole: no ticket contradicts another, every ruling is applied everywhere it bears, and every pointer opens. Each place it would guess, look outside, or reopen a decision is a defect; fix it in place. Text left from an earlier draft that no longer holds is removed, and the tests agree with the decisions they prove.
