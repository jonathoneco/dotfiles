## Beads Issue Tracking (ENFORCED)

When a project has `.beads/`, beads issue tracking is **mandatory**.

- **STOP before editing code** — you must have an `in_progress` beads issue first. No exceptions: not for "simple" one-line changes, not for "quick" config tweaks, not for "obvious" bug fixes.
- Run `bd ready` and `bd list --status=open` before starting any work
- Search closed issues for context BEFORE reading code — closed issues are your primary source of truth for what was built and where
- Close issues with `bd close <id> --reason="..."` when done
- Run `bd sync` at session end, before git push
- For complex work: break into subtasks with dependencies via `bd dep add`

**If you are about to edit a file without an in_progress issue, STOP and create/claim one first.**

### Essential Commands

```bash
bd ready                              # Unblocked work
bd list --status=open                 # All open issues
bd show <id>                          # Issue details + deps
bd create --title="..." --type=task --priority=2
bd update <id> --status=in_progress   # Claim work
bd close <id> --reason="what was done"
bd close <id1> <id2>                  # Close multiple
bd sync                               # Sync with git
```

### Complex Work

Break into tagged subtasks with dependencies:
```bash
bd create --title="[Layer] description" --type=task --priority=2
bd dep add <child-id> <parent-id>     # child blocked by parent
```

Tags: `[API]`, `[UX]`, `[DB]`, `[Service]`, `[Bug]`, `[Refactor]`, `[Feature]`

Work sequentially via `bd ready` -> claim -> implement -> close -> repeat.

### Issue Descriptions

```
Problem: What broke or what's needed
Solution: What was implemented
Files: Key files modified
```

### Key Concepts

- **Priority**: P0=critical, P1=high, P2=medium, P3=low, P4=backlog (numbers only)
- **Types**: task, bug, feature, epic, question, docs
- **Dependencies**: `bd dep add <issue> <depends-on>`, `bd ready` shows only unblocked

### Git Worktrees

If the project uses worktrees for parallel sessions:
- Never switch branches or manage worktrees (user handles this)
- Claim issues immediately and `bd sync` frequently to coordinate
- `git pull` at session start to see other sessions' claims

### Session End Checklist

```bash
git status              # Check changes
git add <files>         # Stage code
bd sync                 # Commit beads
git commit -m "..."     # Commit code
bd sync                 # Catch new beads changes
git push                # Push to remote
```

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
