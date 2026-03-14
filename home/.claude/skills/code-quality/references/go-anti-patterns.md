# Go Anti-Patterns

These rules exist because agent-generated code repeatedly introduced these anti-patterns, causing silent production bugs. Every rule has a concrete WRONG/RIGHT example.

## Fail closed, never fail open

Missing configuration, secrets, or dependencies = **hard error**, not a graceful fallback. Never generate unsigned tokens, skip auth checks, or degrade security because a secret isn't set. If a required value is absent, return an error or refuse to start.

```go
// WRONG — silent security degradation
if hmacSecret == "" {
    return makeUnsignedToken(...)
}

// RIGHT — fail closed
if hmacSecret == "" {
    return "", fmt.Errorf("WEBHOOK_HMAC_SECRET is required")
}
```

## Never swallow errors

Every error return must be checked. No `_, _ =` on DB calls, no `_ =` on template renders or JSON encodes. If an operation can fail, handle the failure — log it, return it, or both.

```go
// WRONG — caller never knows the DB write failed
_, _ = s.pool.Exec(ctx, "UPDATE ...", args...)

// WRONG — client gets empty/broken response silently
_ = h.Renderer.Render(w, "template.html", data)

// RIGHT
if _, err := s.pool.Exec(ctx, "UPDATE ...", args...); err != nil {
    return fmt.Errorf("update plaid item: %w", err)
}
```

## Never fabricate data

When an operation fails or a dependency is nil, **do not** return synthetic defaults (fake UUIDs, empty JSON, zero values with nil error). Fabricated data looks valid to callers and hides wiring/infrastructure failures.

```go
// WRONG — masks that the DB pool is nil
if s.pool == nil {
    return uuid.New(), 3, 0.40, nil
}

// RIGHT
if s.pool == nil {
    return uuid.Nil, 0, 0, fmt.Errorf("email threading: database pool is nil")
}
```

## Always handle both branches

If you write `if err == nil { ... }`, you **must** write an else that handles the error. Conditional-only-on-success leaves the failure path with stale/zero data and no indication anything went wrong.

```go
// WRONG — page renders with BorrowerCount=0 on error, no indication of failure
if err == nil {
    data.BorrowerCount = len(borrowers)
}

// RIGHT
borrowers, err := s.ListBorrowers(ctx)
if err != nil {
    slog.Error("list borrowers", "error", err)
    http.Error(w, "Internal Server Error", 500)
    return
}
data.BorrowerCount = len(borrowers)
```

## Constructor injection only

All dependencies must be available at construction time via `NewXxxService(...)`. Do not use setter injection (`SetXxxDependency`) or post-construction callbacks. If this creates a circular dependency, **restructure the initialization order** — don't paper over it with setters and nil-check guards.

```go
// WRONG — setter injection with nil-check guards everywhere
type EmailService struct {
    pool   *pgxpool.Pool
    sender Sender // nil until SetSender called
}

func (s *EmailService) SetSender(sender Sender) {
    s.sender = sender
}

func (s *EmailService) Send(ctx context.Context, msg Message) error {
    if s.sender == nil {
        return fmt.Errorf("sender not configured")
    }
    return s.sender.Send(ctx, msg)
}

// RIGHT — constructor injection, all deps required at creation
func NewEmailService(pool *pgxpool.Pool, sender Sender) *EmailService {
    return &EmailService{pool: pool, sender: sender}
}
```

## Return complete results

Functions that claim to analyze multiple inputs must actually analyze all of them. Do not short-circuit on the first match when the contract implies comprehensive analysis.

```go
// WRONG — only compares first pair, ignores remaining sources
func compareCrossSources(sources []Source) ([]Discrepancy, error) {
    if len(sources) < 2 {
        return nil, nil
    }
    return compare(sources[0], sources[1])
}

// RIGHT — compares all pairs
func compareCrossSources(sources []Source) ([]Discrepancy, error) {
    var results []Discrepancy
    for i := 0; i < len(sources); i++ {
        for j := i + 1; j < len(sources); j++ {
            discs, err := compare(sources[i], sources[j])
            if err != nil {
                return nil, fmt.Errorf("compare %s vs %s: %w", sources[i].Name, sources[j].Name, err)
            }
            results = append(results, discs...)
        }
    }
    return results, nil
}
```

## No divergent copies of the same interface

Go idiom is to define small interfaces at the consumer site — that's fine. A handler that only needs `LogAuditEvent()` should define a narrow interface locally. But do not create multiple interfaces with the **same name and similar method sets** that diverge over time. If `AuditLogger` exists in three packages with three different method signatures, that's a bug, not consumer-side narrowing.

```go
// WRONG — three packages, same name, divergent signatures
// package handlers
type AuditLogger interface {
    LogAuditEvent(ctx context.Context, event AuditEvent) error
}

// package services
type AuditLogger interface {
    LogAuditEvent(ctx context.Context, action string, details map[string]any) error
    ListAuditEvents(ctx context.Context, entityID uuid.UUID) ([]AuditEvent, error)
}

// package middleware
type AuditLogger interface {
    Log(ctx context.Context, msg string)
}

// RIGHT — one canonical interface, consumer-site narrowing with different names
// package audit (canonical)
type Logger interface {
    LogAuditEvent(ctx context.Context, event AuditEvent) error
    ListAuditEvents(ctx context.Context, entityID uuid.UUID) ([]AuditEvent, error)
}

// package handlers (narrow consumer interface — different name)
type AuditEventLogger interface {
    LogAuditEvent(ctx context.Context, event AuditEvent) error
}
```

## No shims, scaffolding, or backward compatibility

**This is the single most common agent anti-pattern.** Agents repeatedly add "just in case" flexibility, migration fallbacks, and compatibility layers that silently accumulate as technical debt.

**YOU MUST NOT add any of the following without explicit user request:**

- **Config knobs for unused targets** — If we deploy to S3, do not add MinIO path-style overrides, endpoint config, or dual-target logic. Build for what we use.
- **Migration/data fallbacks** — Do not add `COALESCE` or `CASE WHEN column IS NULL` to handle rows that "might predate" a migration. If old data needs backfilling, write a migration to backfill it. Do not code around missing data at query time.
- **Cleanup code for removed features** — If cookie-based auth was replaced by WorkOS, do not add code to clear old cookies "in case they exist." The old system is gone. Remove references, don't maintain them.
- **Setter injection to avoid refactoring** — If a dependency isn't available at construction time, restructure the initialization order. Do not add `SetXxxDependency()` methods with nil-check guards throughout the codebase.
- **"Future-proofing" abstractions** — Do not add interfaces, factories, or strategy patterns for hypothetical future requirements. Build what's needed now. If requirements change, refactor then.
- **Compatibility wrappers for deprecated approaches** — If something is deprecated, don't write code that accommodates it.

**The test:** If you're about to add code that handles a scenario the system doesn't currently face, **stop**. Either the scenario is real and needs a migration/cleanup, or it's hypothetical and the code shouldn't exist.
