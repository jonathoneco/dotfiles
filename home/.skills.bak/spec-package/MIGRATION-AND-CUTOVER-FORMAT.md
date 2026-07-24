# 04-migration-and-cutover.md

Required when persisted data, production behavior, scheduled work, or old code paths change.

Include:

- widen/backfill/cutover/narrow plan when schema narrows
- production row audit gates
- smoke tests and evidence commands
- rollback limits
- temporary validation states or events and their replacement
- deletion inventory or pointer to `retirement-map.md`
- caller and scheduler cleanup
- generated artifact cleanup

Do not allow schema narrowing before backfill and row-audit evidence exists.

## Template

```md
# Migration And Cutover

## Current production shape

...

## Target shape

...

## Widen

...

## Backfill

...

## Cutover

...

## Narrow

...

## Smoke evidence

...

## Rollback limits

...

## Temporary validation artifacts

| Artifact | Why it exists | Replacement | Removal gate |
| -------- | ------------- | ----------- | ------------ |
| ...      | ...           | ...         | ...          |

## Cleanup

...
```
