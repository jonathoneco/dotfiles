# Code Quality Rules — MANDATORY

These rules exist because agent-generated code repeatedly introduces anti-patterns that cause silent production bugs. **Violating these rules creates hard-to-debug failures.**

## Fail closed, never fail open

Missing configuration, secrets, or dependencies = **hard error**, not a graceful fallback. Never generate unsigned tokens, skip auth checks, or degrade security because a secret isn't set. If a required value is absent, return an error or refuse to start.

```
(example — adapt to your project)

WRONG — silent security degradation:
  if hmacSecret == "" { return makeUnsignedToken(...) }

RIGHT — fail closed:
  if hmacSecret == "" { return error("WEBHOOK_HMAC_SECRET is required") }
```

## Never swallow errors

Every error return must be checked. No discarding error values on database calls, template renders, or JSON encodes. If an operation can fail, handle the failure — log it, return it, or both.

```
(example — adapt to your project)

WRONG — caller never knows the DB write failed:
  _, _ = db.Exec(ctx, "UPDATE ...", args...)

RIGHT:
  result, err = db.Exec(ctx, "UPDATE ...", args...)
  if err != nil { return wrap(err, "update item") }
```

## Never fabricate data

When an operation fails or a dependency is nil, **do not** return synthetic defaults (fake IDs, empty JSON, zero values with nil error). Fabricated data looks valid to callers and hides wiring/infrastructure failures.

```
(example — adapt to your project)

WRONG — masks that the DB pool is nil:
  if pool == nil { return newID(), 3, 0.40, nil }

RIGHT:
  if pool == nil { return error("database pool is nil") }
```

## Always handle both branches

If you write `if err == nil { ... }`, you **must** write an else that handles the error. Conditional-only-on-success leaves the failure path with stale/zero data and no indication anything went wrong.

## Constructor injection only

All dependencies must be available at construction time. Do not use setter injection or post-construction callbacks. If this creates a circular dependency, **restructure the initialization order** — don't paper over it with setters and nil-check guards.

## Return complete results

Functions that claim to analyze multiple inputs must actually analyze all of them. Do not short-circuit on the first match when the contract implies comprehensive analysis.

## No divergent copies of the same interface

It's fine to define narrow interfaces at the consumer site. But do not create multiple interfaces with the **same name and similar method sets** that diverge over time. If `FooService` exists in three packages with three different method signatures, that's a bug, not consumer-side narrowing.

## No shims, scaffolding, or backward compatibility unless explicitly requested

**This is the single most common agent anti-pattern.** Agents repeatedly add "just in case" flexibility, migration fallbacks, and compatibility layers that silently accumulate as technical debt.

**YOU MUST NOT add any of the following without explicit user request:**

- **Config knobs for unused targets** — Build for what the project actually uses, not hypothetical alternatives
- **Migration/data fallbacks** — Do not add conditional handling for data that "might predate" a migration. If old data needs backfilling, write a migration to backfill it
- **Cleanup code for removed features** — If a feature was replaced, remove references instead of maintaining compatibility
- **Setter injection to avoid refactoring** — Restructure initialization order instead of adding setter methods with nil-check guards
- **"Future-proofing" abstractions** — Do not add interfaces, factories, or strategy patterns for hypothetical future requirements
- **Compatibility wrappers for deprecated approaches** — If something is deprecated, don't write code that accommodates it

**The test:** If you're about to add code that handles a scenario the system doesn't currently face, **stop**. Either the scenario is real and needs a migration/cleanup, or it's hypothetical and the code shouldn't exist.
