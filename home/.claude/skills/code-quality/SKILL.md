---
name: code-quality
description: "Code quality anti-patterns and correctness checklists for Go + HTMX projects. Activates when editing Go source files or HTML templates. Propagate to review agents and implementation subagents via skills: [code-quality] frontmatter."
---

# Code Quality

This skill provides anti-pattern detection rules and correctness checklists
for Go backend and HTMX frontend code. It exists as a skill (not a rule)
so that it propagates to subagents — review agents, implementation agents,
and any spawned helper all inherit this knowledge.

## When This Activates

- Editing `.go` files
- Editing `.html` template files
- Running code review commands (`/work-review`)
- Spawning review or implementation agents

## References

- **go-anti-patterns** — Go-specific anti-patterns that cause silent production bugs
- **htmx-checklist** — HTMX target/swap/response correctness checks

## How to Use

When writing or reviewing Go code, check against `references/go-anti-patterns.md`.
When writing or reviewing HTMX templates or handlers, check against
`references/htmx-checklist.md`.

When spawning subagents that will write or review code, include
`skills: [code-quality]` in the agent spawn to propagate these rules.
