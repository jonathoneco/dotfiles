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
