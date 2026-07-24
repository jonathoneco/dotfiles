# 05-implementation-plan.md

Purpose: executable work plan.

Order slices by deploy safety and dependency, not by narrative neatness.

Include:

- ordered slices
- exact files and symbols to edit
- tests per slice
- acceptance criteria
- stop conditions
- merge or PR sequence when relevant
- implementation log section or pointer
- known deviations from the canonical spec, if any

A slice is not ready if the implementer must answer a product, architecture, schema, or migration question before coding.

## Template

```md
# Implementation Plan

## Merge shape

...

## Slice 1: <name>

Files and symbols:

- ...

Tests:

- ...

Acceptance:

- [ ] ...

Stop conditions:

- ...

## Slice 2: <name>

...

## Implementation log

...
```
