## System

- EndeavourOS (Arch-based), Sway WM, zsh, foot terminal
- Tool versioning via mise (Go, Node, Python)
- Packages: check AUR before compiling from source
- Desktop notifications via notify-send (swaync)

## Git

- Conventional commits: feat:, fix:, chore:, docs:, refactor:, test:, infra:
- Never force push to main/master
- Prefer specific file staging over `git add -A`

## Claude Code Behavior

- Parallel tool calls: batch independent Glob, Grep, Read, Bash calls
  in a single response whenever they don't depend on each other's output
- Plan mode: use EnterPlanMode for requests touching 3+ files or with
  ambiguous requirements. Outline approach before writing code.
- Concise responses; elaborate only when asked
- Absolute file paths in output
- After 2 failed attempts at the same approach, stop and ask — don't loop
- For ambiguous tasks, ask a clarifying question before implementing
- Use sub-agents for exploratory research to keep main context clean
- After context compaction, re-check project state before continuing
- If a task would benefit from a multi-agent team (review, parallel implementation, spec analysis), suggest or proactively spin one up

## Proactive Agent Usage

- **Default to delegation**: For tasks touching 3+ files or involving research + implementation, spin up agents rather than doing everything inline
- **Explore agents**: Use for any codebase search that might take >3 queries — grep/glob cascades, finding usage patterns, understanding call chains
- **Parallel agents**: When a task decomposes into independent work (e.g., frontend + backend, tests + implementation, multiple file refactors), launch agents in parallel
- **Review agents**: After significant changes, proactively spin up a review agent to check for regressions, missed edge cases, or HTMX target/swap issues
- **Research agents**: Before implementing unfamiliar patterns, spawn an agent to search closed beans issues, git history, and docs for prior art
- **Don't ask permission to use agents** — just use them when appropriate. The user prefers autonomous delegation over asking "should I use agents for this?"

## Context Gathering & Management

- **Aggressively use subagents for context**: Before modifying code, spawn Explore agents to build a full picture — don't rely on partial reads in the main thread
- **Pre-task reconnaissance**: At the start of any non-trivial task, launch parallel subagents to gather context (file structure, dependencies, usage sites, related tests, git history) before writing a single line
- **Offload large reads**: When understanding a module or feature requires reading 5+ files, delegate to an Explore agent and get a synthesized summary back — keep the main context window lean
- **Context recovery after compaction**: When conversation history is compressed, immediately spawn an agent to re-survey the working area rather than guessing from stale memory
- **Dependency mapping**: Before refactoring, spawn an agent to trace all callers, importers, and test coverage for the target code — never refactor blind
- **Parallel context sweeps**: When a task spans multiple packages or domains, launch one agent per domain to gather context concurrently, then synthesize results before planning

## Automatic Team Orchestration

### When to spin up a team (don't ask — just do it)

- **Cross-cutting changes**: Task touches 3+ packages/modules or spans frontend + backend + infra
- **Research + implement**: Task requires significant investigation before coding (e.g., "upgrade auth system", "migrate to new API") — split into researcher + implementer
- **Parallel workstreams**: Task clearly decomposes into independent subtasks that can run concurrently (e.g., "add endpoint + write tests + update docs")
- **Spec-to-code**: User provides a spec, RFC, or issue with multiple acceptance criteria — spin up agents per criterion
- **Large refactors**: Renaming, restructuring, or migrating patterns across many files — coordinator + workers per directory/module
- **Review-gated work**: Any change where you'd want a second opinion — implementer + reviewer running in parallel, reviewer checks work before reporting back

### How to choose team composition

Name agents as **domain experts**, not process roles. Think about what knowledge the task demands, then create specialists with that framing.

- Invent role names that match the problem domain: `ml-expert`, `loan-originator`, `devops-engineer`, `product-manager`, `auth-specialist`, `database-architect`, `css-wizard`, `api-designer`, etc.
- The agent's name primes its behavior — a `payment-systems-expert` will reason differently about Stripe integrations than a generic "implementer"
- Pick experts the way you'd staff a consulting engagement: who needs to be in the room for this specific problem?
- Don't force agents into generic buckets (researcher/implementer/tester) — one agent can research, implement, and test within its domain
- Mix read-only agents (Explore, Plan) with read-write agents (general-purpose) based on whether the expert needs to change code or just advise
- When the task spans domains (e.g., "add ML-powered fraud detection to checkout"), each domain expert owns their slice end-to-end rather than splitting by process phase

### Guidelines

- **Prefer small teams** (2-3 agents) over large ones — coordination cost grows fast
- **Always have a task list**: Use TaskCreate to define work items before spawning teammates so agents can self-serve
- **Use plan mode for the team lead**: The lead should plan, create tasks, then delegate — not do implementation work itself
- **Shut down agents when done**: Don't leave idle agents running — send shutdown_request as soon as their work is complete
- **Escalate blockers quickly**: If an agent is stuck, have it message the lead rather than spinning — the lead can reassign or unblock

## Go Conventions

- Error wrapping: `fmt.Errorf("context: %w", err)`
- Structured logging: `slog`
- Table-driven tests, colocated `_test.go` files
- `gofmt` before committing
- Constructor injection: `NewXxxService(pool, ...)`

## Shell & Scripting

- Prefer POSIX sh for scripts unless bash features are needed
- Use shellcheck for linting shell scripts
- Quote all variables in shell scripts

## Serena

Serena MCP tools provide LSP-backed semantic code navigation. When available:
- Run `/serena-activate` at session start (auto-triggered by SessionStart hook)
- After context compaction, re-run `/serena-activate` to restore Serena guidance
- Prefer `find_symbol`, `find_referencing_symbols`, `get_symbols_overview` over reading entire files
- Use `rename_symbol` for cross-file renames (no Claude Code equivalent)
- Use `get_symbols_overview` before reading a file to understand its structure first

### MCP Tool Preference

BIAS: Strongly toward Serena MCP tools when the task involves code navigation or understanding.
DEFAULT: Use Serena tools, not built-in Read/Grep/Glob, for exploring code structure.

| Task | Use This | Not This |
|------|----------|----------|
| Find a function/class/method | `mcp__serena__find_symbol` | Grep/Glob |
| Find all usages of a symbol | `mcp__serena__find_referencing_symbols` | Grep |
| Understand a file's structure | `mcp__serena__get_symbols_overview` | Read (full file) |
| Replace an entire function body | `mcp__serena__replace_symbol_body` | Edit |
| Rename across files | `mcp__serena__rename_symbol` | Edit replace_all |

## Open Brain

The user runs a self-hosted Open Brain MCP server (personal knowledge base, semantic search over Postgres + pgvector). Source: `~/src/openbrain` (private repo `jonathoneco/openbrain`, sibling public clone at `~/src/OB1`). Autostarts via the `openbrain-mcp.service` user systemd unit — assume it's running unless verified otherwise.

### Memory: two systems running in parallel (experiment in progress)

The user has TWO memory systems active **at the same time** and is treating this as an experiment to see which is better for what. Use both. Do not gate one in favor of the other.

| System | Role | When it acts |
|---|---|---|
| **Auto-memory** (`.claude/memory/*.md`) | Passive context loaded into future Claude sessions. Facts, preferences, corrections, project state. | Per the standard auto-memory rules in your system prompt: write `user`/`feedback`/`project`/`reference`-typed memories when their conditions are met. Continue this normally — *the existence of Open Brain does NOT suppress it.* |
| **Open Brain MCP** (`mcp__open-brain__capture_thought` / `search_thoughts`) | Actively-searchable personal knowledge base. Thoughts the user wants to retrieve later by meaning. | When the user explicitly captures ("Remember this:", "Save this:", "Capture:", "Note that…", first-person observations they're saving for themselves), call `capture_thought` in addition to any normal auto-memory write that the same statement might trigger. |

**They overlap. Both can fire on the same statement.** Example: user says *"Remember this: I just got the brain working; the OpenRouter privacy toggles are all off."* Possible outcomes — both legitimate:
- Auto-memory writes a `project`-type note ("Open Brain stack working since 2026-04-28; OpenRouter privacy toggles off")
- Open Brain captures the first-person observation as an `observation`-type thought
- Both happen — fine. The user is comparing how each system surfaces the same fact later.

When the user **searches** ("what did I capture about X" / "find my notes about Y") use `mcp__open-brain__search_thoughts`. Auto-memory is loaded passively at session start; it is not the right tool for retrieval queries.

When the user wants Claude to remember **how to behave** (preferences, corrections, conventions) — that's auto-memory, full stop. Don't route those to Open Brain.

### When the Open Brain MCP isn't connected

Each project's MCP servers are configured per-project in `~/.claude.json`. If `mcp__open-brain__*` tools aren't visible in the current session, options:

1. **Add for this project** (one-shot):
   ```bash
   claude mcp add --transport http open-brain \
     http://127.0.0.1:54321/functions/v1/open-brain-mcp \
     --header "x-brain-key: <key from Notion>"
   ```
   Then start a new Claude Code session.
2. **Verify the server itself**:
   ```bash
   systemctl --user status openbrain-mcp.service
   curl -sS -o /dev/null -w "%{http_code}\n" -X POST \
     -H "Accept: application/json, text/event-stream" \
     -H "Content-Type: application/json" \
     -H "x-brain-key: <key>" \
     -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
     http://127.0.0.1:54321/functions/v1/open-brain-mcp
   ```
   - Service inactive → `systemctl --user start openbrain-mcp.service`
   - 502 → runtime mid-restart, wait 30s and retry
   - 401 → access key mismatch (check Notion vs `~/src/openbrain/supabase/functions/.env`)

### When Open Brain is down

If `capture_thought` fails because the server isn't reachable, tell the user, offer to start the service, and proceed with the auto-memory write anyway (if applicable per its standard rules). Don't pretend the capture happened — they should know the searchable copy is missing — but don't *withhold* the auto-memory write either. The two systems are independent.

### Credentials

Live in the user's Notion page "Open Brain — Self-Host Credentials" (Notes DB, linked to the Personal Agent project). Read from there when needed; do not echo secrets back into chat or commit them.
