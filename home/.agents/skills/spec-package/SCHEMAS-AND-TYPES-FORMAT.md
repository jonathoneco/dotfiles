# 01-schemas-and-types.md

Use when the work changes data shape, API shape, type contracts, generated APIs, or persisted records.

Include:

- canonical shapes
- old-to-new mapping
- field semantics
- generated API impact
- validation rules
- compatibility rules
- removal gates for temporary fields

Every field name must be checked against current code unless it is explicitly new.

## Template

```md
# Schemas And Types

## Current shape

...

## Target shape

...

## Old-to-new mapping

| Old field/type | New field/type | Semantics | Migration note |
| -------------- | -------------- | --------- | -------------- |
| ...            | ...            | ...       | ...            |

## Validation rules

...

## Compatibility and removal gates

...
```
