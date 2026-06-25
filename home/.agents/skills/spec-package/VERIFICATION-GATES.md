# Verification Gates

Run the gates that match the package risk. Use exact commands where possible and record unresolved gaps in the package.

## Source Grounding Gate

- The package cites raw source context, not only a summary.
- Product/PRD docs have been checked when they could change the interpretation.
- Existing code paths have been traced from producer to consumer.
- Subagent findings have been audited against files, not accepted on trust.

## Symbol And Vocabulary Gate

- Every referenced file exists.
- Every referenced symbol exists or is explicitly planned as new.
- Generated APIs and type names match current reality.
- Stale terms, old names, and mechanical replacement artifacts have been grepped.
- One domain term is used per idea across the package.

## Design Coherence Gate

- The canonical design spec answers what and why before implementation mechanics.
- Sibling docs agree with the canonical spec.
- User corrections are reflected across spec, schemas/types, interfaces/behavior, dataflow, implementation, tests, ADRs, and glossary.
- Intended behavior changes are separated from bugs or accidental regressions.
- Open questions are explicit and not buried inside implementation steps.

## Interface Behavior Gate

- Function signatures, endpoint contracts, service methods, mutations, queries, actions, and worker entrypoints are listed when they change.
- Arguments, return values, errors, side effects, idempotency, and caller responsibilities are explicit.
- Old callable contracts are mapped to replacements or marked for deletion.
- Behavior cases align with `00-design-spec.md` and the test plan.
- Current signatures are verified against code unless explicitly new.

## Dataflow Gate

- Before/after flow diagrams show the runtime change when flow changes.
- Entity relationships are shown when persisted entities, ownership, or lineage changes.
- State diagrams are shown when lifecycle states, terminal states, retries, or temporary validation states change.
- Boundary diagrams are shown when the slice crosses, protects, or forbids service/provider/subscriber/scheduler boundaries.
- Diagrams state invariants and non-flows, not just happy paths.

## Deliverable Shape Gate

- Each package deliverable has its own markdown file.
- The README lists every package deliverable and the read order.
- Each deliverable owns one concern and links to sibling docs instead of duplicating them.
- Conditional deliverables are either present or explicitly omitted in the README with a reason.
- The deliverable reference for each included file has been loaded before writing or reviewing it.

## Execution Gate

- Implementation slices are ordered by dependency and deploy safety.
- Each slice names files, symbols, tests, acceptance criteria, and stop conditions.
- The plan is behavior-correct after each merge point when staged delivery matters.
- Broad "clean this up" bullets have been replaced with concrete work.
- Handoffs reference the package and only add worktree state, gotchas, and open choices.

## Migration And Retirement Gate

- Every old symbol, file, API, scheduler, generated artifact, fixture, and test has delete/rename/keep status.
- Every replaced caller is mapped to the new path.
- Temporary adapters, shadows, and compatibility fields have removal gates.
- Schema narrowing waits until backfill and production-row audit evidence exist.
- Rollback limits are stated plainly.

## Instrumentation Gate

- Runtime behavior changes have factual events or logs sufficient to debug production behavior.
- Event payloads carry correlation identifiers and domain identifiers needed to trace the flow.
- Facts/events are separated from derived metrics, thresholds, and policy interpretation.
- Temporary validation facts are explicitly distinguished from product facts.
- Smoke evidence commands or queries are listed for rollout and cutover.
- Claims and non-claims are listed so the package cannot overstate what the slice proves.
- Absence assertions prove forbidden side effects did not happen when boundary safety matters.
- Subscriber, scheduler, provider, and generated-artifact boundaries are checked when relevant.
- Temporary migration instrumentation has a removal gate.
- Privacy and secret-handling constraints are stated for any logged payload fields.

## Test And Evidence Gate

- Tests cover the original bug or motivating risk.
- Tests cover intended behavior changes and rejected regressions.
- Migration helpers have deterministic tests.
- Architecture or contract tests protect ownership boundaries when relevant.
- Exact verification commands are listed.
- External or production evidence claims are scoped to the target where they were actually run.
