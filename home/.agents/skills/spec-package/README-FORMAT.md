# README.md

Purpose: package index and operating contract.

Keep it short. It should tell the next agent what to read, what is canonical, and whether the package is ready to implement.

Include:

- status and provenance
- read order
- canonical source-of-truth doc
- package scope and non-scope
- deliverable inventory
- open decisions
- implementation readiness state

Avoid duplicating design details from `00-design-spec.md`.

## Template

```md
# <Package Name>

Status: <draft | ready for implementation | blocked>
Provenance: <raw sources used>
Canonical intent: `00-design-spec.md`

## Read order

1. `00-design-spec.md`
2. ...

## Scope

...

## Deliverables

- `...` - ...

## Open decisions

- ...

## Implementation readiness

...
```
