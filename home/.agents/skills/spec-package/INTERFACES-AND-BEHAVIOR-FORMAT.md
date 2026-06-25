# 02-interfaces-and-behavior.md

Use when the work adds, replaces, consolidates, or changes callable contracts: functions, public helpers, service methods, mutations, queries, actions, API endpoints, worker entrypoints, or event handlers.

Include:

- function or endpoint signatures
- arguments and return values
- behavior by case
- error behavior
- ownership boundaries
- caller responsibilities
- side effects and idempotency
- replacement mapping for old callable contracts

Keep this separate from schemas/types and dataflow. Schemas describe data shape; this doc describes callable behavior. Dataflow describes how calls compose at runtime.

## Template

```md
# Interfaces And Behavior

## Public contracts

| Contract | Signature | Owner | Callers | Replacement |
| -------- | --------- | ----- | ------- | ----------- |
| ...      | ...       | ...   | ...     | ...         |

## Behavior

### `<contract name>`

Inputs:

- ...

Returns:

- ...

Cases:

- ...

Errors:

- ...

Side effects:

- ...

Caller responsibilities:

- ...

## Removed or replaced contracts

...
```
