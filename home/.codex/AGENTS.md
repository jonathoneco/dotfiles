## System

- EndeavourOS (Arch-based), Sway WM, zsh, foot terminal
- Tool versioning via mise (Go, Node, Python)
- Packages: check AUR before compiling from source
- Desktop notifications via notify-send (swaync)

## Git

- Conventional commits: feat:, fix:, chore:, docs:, refactor:, test:, infra:
- Never force push to main/master
- Prefer specific file staging over `git add -A`

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

## Workflow Harness

Multi-session workflow system for structured feature development. When the user asks to start, check, or work on a workflow, read `~/.codex/workflow-guide.md` for the full protocol.

At session start: check `.workflows/*/state.json` for entries where `archived_at` is null. If found, mention the active workflow name, current phase, and suggest regrounding.

Natural language triggers (Codex has no slash commands — respond to phrases like these):
- "start a workflow" / "new workflow" -> Start operation
- "workflow status" -> Status check
- "research <topic>" (in active workflow) -> Research operation
- "plan the architecture" -> Plan operation
- "write specs" -> Spec operation
- "decompose" / "break down the work" -> Decompose operation
- "implement" / "next issue" / "pick up work" -> Implement operation
- "checkpoint" / "save progress" -> Checkpoint operation
- "reground" / "recover context" -> Reground operation
- "archive workflow" -> Archive operation
