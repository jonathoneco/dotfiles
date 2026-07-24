---
name: spec-package
description: Create source-grounded engineering spec packages for non-trivial product, architecture, migration, or refactor work. Use when the user asks to turn a design conversation, PRD, chat transcript, implementation plan, or WIP docs into a package that another agent or engineer can execute without rediscovering decisions.
---

# Spec Package

Create an implementation-driving package of markdown deliverables. Do not interview from scratch when the conversation, PRD, transcript, code, or existing docs already answer the question. Synthesize what is known, verify it against real code, and mark unresolved decisions explicitly.

## Process

### 1. Gather context

Build an evidence map from raw source material:

- chats, transcripts, PRDs, comments, handoffs, and existing WIP docs
- current code paths, producers, consumers, scheduled jobs, generated APIs, tests, and fixtures
- product/domain docs that could overturn a code-only interpretation
- prior review findings and unresolved decisions

For broad sweeps, use read-only subagents with narrow report shapes. Audit their claims before accepting them.

### 2. Resolve decisions

If product, architecture, data-model, or migration choices are still open, grill the user before freezing the package. Convert user nudges into explicit decisions, then propagate them through every affected deliverable.

### 3. Create the package

Create the package under `goals/<name>/`. These packages are active implementation artifacts, not durable architecture or product docs. If a decision should become durable, include a glossary patch or ADR that can be promoted separately.

Create one markdown file per deliverable. Use the format docs below. After the canonical design spec exists, use one subagent per substantive deliverable whenever the package has more than two deliverables. Give each subagent the evidence map, `00-design-spec.md`, already-written prerequisite docs, its format file, and an exact output path. Keep write scopes disjoint.

### 4. Integrate and verify

Review every subagent-written deliverable in the main thread. Reconcile contradictions against `00-design-spec.md`, fill cross-links, update the README read order, and run [VERIFICATION-GATES.md](VERIFICATION-GATES.md).

## Deliverables

Write in this order:

- `README.md` — use [README-FORMAT.md](README-FORMAT.md)
- `00-design-spec.md` — use [DESIGN-SPEC-FORMAT.md](DESIGN-SPEC-FORMAT.md)

Then create prerequisite deliverables, in parallel where independent:

- `01-schemas-and-types.md` — use [SCHEMAS-AND-TYPES-FORMAT.md](SCHEMAS-AND-TYPES-FORMAT.md)
- `02-interfaces-and-behavior.md` — use [INTERFACES-AND-BEHAVIOR-FORMAT.md](INTERFACES-AND-BEHAVIOR-FORMAT.md)
- `03-dataflow.md` — use [DATAFLOW-FORMAT.md](DATAFLOW-FORMAT.md)
- `04-migration-and-cutover.md` — use [MIGRATION-AND-CUTOVER-FORMAT.md](MIGRATION-AND-CUTOVER-FORMAT.md)
- `retirement-map.md` — use [RETIREMENT-MAP-FORMAT.md](RETIREMENT-MAP-FORMAT.md)

Then create synthesis deliverables after prerequisites exist:

- `05-implementation-plan.md` — use [IMPLEMENTATION-PLAN-FORMAT.md](IMPLEMENTATION-PLAN-FORMAT.md)
- `06-test-plan.md` — use [TEST-PLAN-FORMAT.md](TEST-PLAN-FORMAT.md)
- `07-instrumentation.md` — use [INSTRUMENTATION-FORMAT.md](INSTRUMENTATION-FORMAT.md)
- `08-glossary-patch.md` — use [GLOSSARY-PATCH-FORMAT.md](GLOSSARY-PATCH-FORMAT.md)
- `adr-0001-<decision>.md` — use [ADR-FORMAT.md](ADR-FORMAT.md)
- `implementation-log.md` — use [IMPLEMENTATION-LOG-FORMAT.md](IMPLEMENTATION-LOG-FORMAT.md)

`05-implementation-plan.md` depends on the flushed-out schemas/types, interfaces/behavior, dataflow, migration/cutover, instrumentation, and retirement-map docs when those docs are relevant. Do not write the implementation plan first and backfill the model later.

Do not omit migration/cutover, instrumentation, tests, or retirement maps when the work changes existing production behavior or replaces a path.

## Quality Bar

- One document is canonical for intent: `00-design-spec.md`. Sibling docs defer to it.
- Implementation slices are junior-drivable: exact files/symbols, tests, acceptance criteria, and stop conditions.
- Old symbols and callers have delete/rename/keep verdicts.
- Stable domain vocabulary beats rollout-shaped names such as phase, lane, adapter, legacy-v2, or temporary implementation names.
- Temporary scaffolding has removal gates.
- Observability facts are separated from derived metrics and policy interpretation.

Before calling the package ready, run [VERIFICATION-GATES.md](VERIFICATION-GATES.md).

## Finish

Report:

- package path
- files created or updated
- open decisions
- verification performed and gaps

If the package is not implementation-ready, say why and point to the blocking section.
