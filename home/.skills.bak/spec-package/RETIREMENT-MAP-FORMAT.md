# retirement-map.md

Use when replacing, consolidating, renaming, or deleting existing code paths.

Include one row per old artifact:

- old symbol, file, API, scheduler, generated artifact, fixture, or test
- current callers
- replacement target
- verdict: delete, rename, keep, or temporary
- removal gate for temporary artifacts
- verification command or grep

This is the "leave no trace" document. If an old live path remains, it must be intentionally kept or explicitly blocked.

## Template

```md
# Retirement Map

| Old artifact | Current callers | Replacement | Verdict                            | Removal gate | Verification |
| ------------ | --------------- | ----------- | ---------------------------------- | ------------ | ------------ |
| ...          | ...             | ...         | delete / rename / keep / temporary | ...          | ...          |

## Blockers

- ...
```
