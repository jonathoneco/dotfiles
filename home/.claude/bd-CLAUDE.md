<!-- bv-agent-instructions-v1 -->

## Beads Workflow

This project uses beads (`bd`) for issue tracking. Issues live in `.beads/` and sync via git.

### Before Any Work

```bash
bd ready              # Find unblocked work
bd list --status=open # All open issues
```

Match user request to existing issue and claim it, or create one first:
```bash
bd update <id> --status=in_progress   # Claim existing
bd create --title="..." --type=task --priority=2  # Or create new
```

**Never edit code without an in_progress issue.**

### Context Gathering

Before reading code, search closed issues via sub-agent (keeps raw output out of main session):
```
Task(subagent_type="Explore", prompt="Search closed beads issues for context about <topic>.
Run: bd list --status=closed | grep -i <keyword>
Then bd show each relevant match.
Return concise summary: relevant files, patterns, key decisions.")
```

Then read specific files from the summary. Only use Explore agents if gaps remain.

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

<!-- end-bv-agent-instructions -->
