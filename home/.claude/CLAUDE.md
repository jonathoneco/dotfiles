## Beads Issue Tracking (ENFORCED)

When a project has `.beads/`, beads issue tracking is **mandatory**. A Stop hook will block you if you modify code without a claimed issue.

- **STOP before editing code** — you must have an `in_progress` beads issue first. No exceptions: not for "simple" one-line changes, not for "quick" config tweaks, not for "obvious" bug fixes.
- Run `bd ready` and `bd list --status=open` before starting any work
- Search closed issues for context BEFORE reading code or using Explore agents — closed issues are your primary source of truth for what was built and where
- Close issues with `bd close <id> --reason="..."` when done
- Run `bd sync` at session end, before git push
- For complex work: break into subtasks with dependencies via `bd dep add`

**If you are about to edit a file without an in_progress issue, STOP and create/claim one first.**

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
- **Research agents**: Before implementing unfamiliar patterns, spawn an agent to search closed beads issues, git history, and docs for prior art
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
