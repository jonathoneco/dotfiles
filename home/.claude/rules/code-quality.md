# Code Quality Rules

These rules are enforced by the `code-quality` skill (`skills: [code-quality]`), which propagates to all subagents. The skill contains the full anti-pattern catalog with Go code examples in `references/go-anti-patterns.md` and HTMX checklist in `references/htmx-checklist.md`.

If the skill is not available (e.g., working outside the dotfiles environment), these are the critical rules:

1. **Fail closed, never fail open** — Missing config/secrets = hard error, not fallback
2. **Never swallow errors** — Every error return must be checked
3. **Never fabricate data** — No synthetic defaults on failure paths
4. **Always handle both branches** — `if err == nil` must have an `else`
5. **Constructor injection only** — No setter injection or post-construction callbacks
6. **Return complete results** — Analyze all inputs, not just the first match
7. **No divergent interface copies** — Same-name interfaces must not diverge
8. **No shims or backward compatibility** — No migration fallbacks, future-proofing, or compatibility layers unless explicitly requested
