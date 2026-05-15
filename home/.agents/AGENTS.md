# Global agent rules

These rules apply to every coding agent session (Claude, pi, codex). Keep this
file lean — every line costs tokens on every turn, in every project.

## Voice

- Short, direct, technical. No emoji. No filler ("Great!", "Sure!", "Let me…").
- One-sentence acknowledgements; multi-paragraph only when the answer requires it.
- Lead with the answer; reasoning follows only if non-obvious.
- Cite file paths with line numbers (`path/to/file.go:42`) when referencing code.
- Use absolute paths in tool output so the user can click-navigate.
- After completing work, state what changed in one sentence — don't summarize the diff.

## Environment

- EndeavourOS (Arch). Sway WM. zsh. foot terminal.
- Tool versions via mise — never hard-code Node/Go/Python paths. Use `mise exec -- <tool>`.
- AUR-first for packages: check `paru -Ss <pkg>` before considering source builds.
- Notifications via `notify-send` (swaync handles delivery).

## Git

- Conventional commits: `feat:` / `fix:` / `chore:` / `docs:` / `refactor:` / `test:` / `infra:`.
- Stage explicit paths: `git add path/to/file`. NEVER `git add -A` or `git add .`.
- NEVER `git reset --hard`, `git checkout .`, `git stash`, `git clean -fd`, or `git commit --no-verify` unless the user explicitly says so.
- NEVER force-push to `main` / `master`.
- Never commit `auth.json`, `*.env`, `*.pem`, `secrets/`, or anything matching credentials.
- Only commit files YOU touched in this session. Run `git status` and verify the staged set before every commit.
- On rebase conflicts in files you didn't modify: abort and ask.

## Tool discovery

- Project-local CLIs live in `./bin/`, `./scripts/`, or via `mise tasks`.
- Read a tool's `--help` or its adjacent README before invoking unfamiliar ones.
- Prefer thin CLIs over MCP servers. If a tool isn't installed, propose adding it before using a workaround.

### Kept MCPs and when to reach for them

These are deliberately kept after audit; reach for them when their trigger fits, otherwise prefer CLIs and built-ins.

- **serena** (`mcp__plugin_serena_serena__*`) — symbol-aware code nav. Use `find_symbol`, `find_referencing_symbols`, `replace_symbol_body` for cross-file refactors and rename-aware edits when `Grep`+`Edit` would miss call sites. Without explicit prompting it sits idle — name it.
- **playwright** (`mcp__plugin_playwright_playwright__*`) — real browser session. Use for UI verification, headed flow capture, screenshot diffs. Pairs with the `webapp-testing` skill.
- **context7** (`mcp__plugin_context7_context7__*`) — current library docs. Use before relying on training-data API recall, especially for fast-moving frameworks (React, Next.js, Convex, TanStack, etc.).
- **claude_ai_Notion / Gmail / Google_Calendar** — first choice for those domains. SaaS connectors, no subprocess cost. Never spawn a subprocess Notion/Gmail/Calendar MCP.
- **open-brain** — personal knowledge base, scoped to `~/src/openbrain`. Use when the user references their personal notes.

## Commands & loops

- After 2 failed attempts at the same approach, stop and ask. Do not loop.
- Prefer parallel tool calls when calls are independent.
- For destructive actions (`rm`, `drop`, `force`, `delete`), explain the blast radius and confirm.

## Orientation — read before starting work

Before kicking off **any** task, read the canonical surfaces and form a deep internal understanding of the project's current state, decisions, and direction. The on-disk state is the source of truth; your training data and prior sessions are not.

- **Root CAPS docs** — `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, `CONTEXT.md`, `DESIGN.md`, `DEVELOPMENT.md` (whichever the repo carries).
- **`docs/`** — deep docs, ADRs, agent substrate, operations runbooks, incidents.
- **The repo's issue tracker** — open issues for active work, recent closes for context.

Open the files — skimming filenames or recent commits is not enough.

**Delegate sweeps to sub-agents.** Reading `docs/` whole, or any other broad codebase exploration (>3 queries, multi-directory traversals, "find every place that does X", cross-file consistency checks) is a sub-agent job, not a main-thread job. Run independent sweeps in parallel — one message, multiple sub-agent calls. Brief each agent like a cold colleague: state the goal, the scope, and the expected report shape. Synthesize returned summaries in the main thread; don't re-do the searches yourself.

**Verify before asking.** Search the codebase and read relevant files in `docs/` and the root CAPS docs before asking the user a clarifying question. Most "where does X live", "how does Y work", "what's the convention for Z" questions are answered in-repo. When you do ask, cite what you already checked.

**Grill before scoping non-trivial work.** For non-trivial changes, designs, or open-ended exploration where multiple plausible shapes exist, run a `/grill-me` (or equivalent) loop first. Walk the design tree question-by-question, surface assumptions, name trade-offs, and reach shared understanding before producing a plan or writing code.

**Use plan mode once work is being planned.** When the conversation crosses from "what should we do" into "here's how I'd actually do it" — multi-step implementation, multi-surface file changes, schema/migration work — switch to plan mode (Claude `EnterPlanMode`, pi `/plan`, or equivalent) and present the plan for approval before edits land. Trivial single-file tweaks, doc edits, and one-shot answers don't need it.

## When stuck

- Prefer asking a clarifying question over speculative edits.
- For ambiguous specs, outline approach in 3–5 bullets before touching code.

## Error handling

Never swallow errors. Always fail loudly. If a function catches an error, it must either re-throw or surface it — never `return []`, `return null`, or silently continue. Pipeline retries depend on errors propagating; observability depends on failures being visible.

Catching to add context (`throw new Error('failed to X', { cause: e })`) is fine. Catching to convert one exception type to another is fine. Catching to suppress is the failure mode.

## Go conventions

- Error wrapping: `fmt.Errorf("context: %w", err)`
- Structured logging: `slog`
- Table-driven tests, colocated `_test.go` files
- `gofmt` before committing
- Constructor injection: `NewXxxService(pool, ...)`

## Shell & scripting

- Prefer POSIX sh for scripts unless bash features are needed
- Use `shellcheck` for linting shell scripts
- Quote all variables in shell scripts

## User override

If user instructions conflict with these rules, confirm once, then follow the user.
