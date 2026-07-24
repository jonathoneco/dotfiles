# 08-glossary-patch.md

Use when the package introduces, renames, or redefines domain terms.

Include:

- new or changed terms
- old terms to stop using
- canonical definitions
- where the durable glossary should be patched
- grep terms to verify drift was removed

Prefer one stable noun per idea. Do not preserve rollout-shaped names as domain vocabulary.

## Template

```md
# Glossary Patch

## Add or update

| Term | Definition | Notes |
| ---- | ---------- | ----- |
| ...  | ...        | ...   |

## Stop using

| Term | Replace with | Reason |
| ---- | ------------ | ------ |
| ...  | ...          | ...    |

## Verification grep

- ...
```
