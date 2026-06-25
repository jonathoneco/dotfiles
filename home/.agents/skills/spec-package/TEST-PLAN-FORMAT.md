# 06-test-plan.md

Purpose: make verification first-class.

Include:

- table-driven cases
- regression cases for the original bug or motivating risk
- intended behavior-change cases
- architecture or contract tests when ownership changes
- boundary and absence assertions for forbidden side effects
- migration helper tests
- exact verification commands
- fixtures to update or retire

Tests should protect observable behavior and ownership boundaries, not the incidental implementation shape.

## Template

````md
# Test Plan

## Regression risks

...

## Test cases

| Behavior | Test file | Fixture | Expected result |
| -------- | --------- | ------- | --------------- |
| ...      | ...       | ...     | ...             |

## Architecture or contract tests

...

## Boundary and absence assertions

| Forbidden side effect | Test or query | Expected absence |
| --------------------- | ------------- | ---------------- |
| ...                   | ...           | ...              |

## Migration tests

...

## Commands

```sh
...
```
````
