# Global agent rules

These rules apply to every coding agent session (Claude Code, Codex, Cursor, pi).
Keep this file lean — every line costs tokens on every turn, in every project.
Harness-specific deltas live in that harness's shim file (e.g. `~/.claude/CLAUDE.md`),
never here and never forked.

## Voice

- Short, direct, technical. No emoji. No filler ("Great!", "Sure!", "Let me…").
- One-sentence acknowledgements; multi-paragraph only when the answer requires it.
- Lead with the answer; reasoning follows only if non-obvious.
- Cite file paths with line numbers (`path/to/file.go:42`) when referencing code.
- Use absolute paths in tool output so the user can click-navigate.
- After completing work, state what changed in one sentence — don't summarize the diff.

## Environment

- Two machines share this config; check `uname -s` when it matters.
- macOS (Darwin): Homebrew for packages. Aerospace WM, Ghostty terminal. Notifications via `terminal-notifier`.
- Arch (EndeavourOS, Linux): AUR-first — check `paru -Ss <pkg>` before source builds. Sway WM, foot terminal. Notifications via `notify-send` (swaync handles delivery).
- Both: zsh. Tool versions via mise — never hard-code Node/Go/Python paths. Use `mise exec -- <tool>`.

## Git

- Conventional commits: `feat:` / `fix:` / `chore:` / `docs:` / `refactor:` / `test:` / `infra:`.
- Stage explicit paths: `git add path/to/file`. NEVER `git add -A` or `git add .`.
- Keep work in a worktree unless the user explicitly says otherwise.
- Before kicking off new work, update `main` from `origin/main`, then create or refresh the task worktree from that up-to-date `main`.
- NEVER `git reset --hard`, `git checkout .`, `git stash`, `git clean -fd`, or `git commit --no-verify` unless the user explicitly says so.
- NEVER force-push to `main` / `master`.
- Never commit `auth.json`, `*.env`, `*.pem`, `secrets/`, or anything matching credentials.
- Only commit files YOU touched in this session. Run `git status` and verify the staged set before every commit.
- On rebase conflicts in files you didn't modify: abort and ask.
- When reverting a merge-from-main, revert specific files surgically (`git checkout <merge>~1 -- <path>`) rather than reverting the merge wholesale — wholesale revert silently drags out every commit the merge brought in, including ones that aren't part of the cleanup intent.
- Before merging a PR, cross-check `git diff --name-only $base..$head` against files the commit-message body names — messages can claim to add files the diff deletes (or vice versa).

## Knowledge placement

- Durable learnings graduate to the repo that owns them: general practice → this file (via the dotfiles repo), project knowledge → that project's agent docs. Harness memory features stay off; a lesson that lives only in one harness's memory is lost to every other harness and every other person.
- Machine-local or provisional notes (box state, tokens/workarounds, anything that can't be pushed) live in `~/.local/state/agent-notes/` — untracked, mode 0700, not a home for secrets.

## Tool discovery

- Project-local CLIs live in `./bin/`, `./scripts/`, or via `mise tasks`.
- Read a tool's `--help` or its adjacent README before invoking unfamiliar ones.
- Prefer thin CLIs over MCP servers. If a tool isn't installed, propose adding it before using a workaround.
- Global skills live in `~/.agents/skills` — the single canonical store, pinned to upstream by `docs/agent-skills.md` in the dotfiles repo. Harnesses read it through symlink farms (`~/.claude/skills`; pi points at Claude's farm). Never edit a farm copy.

### Shared MCP capabilities

Use configured MCPs when their capability fits the task; otherwise prefer CLIs and built-ins.

- **Serena / semantic code navigation** — symbol-aware code navigation and rename-safe edits. Use it for cross-file refactors, call-site discovery, and symbol-body replacement when text search plus direct edits would miss references.
- **Playwright / browser control** — real browser interaction for UI verification, headed flow capture, console inspection, and screenshot diffs. Pair it with the project's web-testing skill when one exists.
- **Context7 / current library docs** — current framework and library documentation. Use it before relying on training-data recall for fast-moving stacks such as React, Next.js, Convex, TanStack, and deployment platforms.
- **Project SaaS connectors** — use team-owned SaaS connectors only when project docs or project skills name them and follow that project's approval gates for external writes.

## Personal tool overlays

These tools apply to Jon's stowed global runtime and personal workflows.

- **OpenBrain** — personal knowledge base, scoped to `~/src/openbrain`. Use when the user references personal notes or asks to retrieve/capture personal knowledge.
- **Personal Notion / Gmail / Google Calendar connectors** — first choice for those personal SaaS domains when configured. Never spawn a subprocess Notion/Gmail/Calendar MCP when the connector is available.

### Local MCP names

These names are runtime-specific hints for Jon's configured harnesses.

- **serena** (`mcp__plugin_serena_serena__*`)
- **playwright** (`mcp__plugin_playwright_playwright__*`)
- **context7** (`mcp__plugin_context7_context7__*`)
- **claude_ai_Notion / Gmail / Google_Calendar**
- **open-brain**

## Commands & loops

- When Jon says "gardening", read that as "leaving the codebase cleaner than we found it."
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

**Use plan mode once work is being planned.** When the conversation crosses from "what should we do" into "here's how I'd actually do it" — multi-step implementation, multi-surface file changes, schema/migration work — switch to plan mode (Claude `EnterPlanMode`, Cursor plan mode, pi `/plan`, or equivalent) and present the plan for approval before edits land. Trivial single-file tweaks, doc edits, and one-shot answers don't need it.

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
