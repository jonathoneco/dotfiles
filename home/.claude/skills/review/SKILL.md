# /review

Run a multi-agent code review on recent changes or specified files.

## Usage

```
/review              # Review uncommitted changes
/review <file/dir>   # Review specific files or directory
/review --full       # Full project architecture review
```

## Workflow

1. **Identify scope**: Determine what to review:
   - No args: `git diff` and `git diff --cached` for uncommitted changes
   - File/dir arg: the specified paths
   - `--full`: entire project structure

2. **Select reviewers**: Based on what changed, spin up relevant review agents as a team:
   - `.go` files (handlers/services/database) → `code-reviewer`
   - `.go` files (handlers) + templates → `htmx-debugger`
   - Auth, middleware, secrets → `security-reviewer`
   - Docker, Makefile, CI → `devops-reviewer`
   - Cross-cutting changes → `systems-architect`
   - Template/CSS/UX changes → `ux-reviewer`
   - SQL, queries, performance-sensitive code → `performance-analyst`
   - ML/LLM/embedding code → `ml-engineer`

3. **Run review team**: Launch selected agents in parallel using TeamCreate. Each agent reviews the changed files through their specialist lens.

4. **Compile report**: Collect findings from all agents and produce a unified, deduplicated report:
   - **Critical** — Must fix before merge
   - **Important** — Should fix, creates tech debt if deferred
   - **Suggestion** — Nice to have, style/optimization

5. **Create issues**: For any Critical or Important findings, offer to create beads issues to track the fixes.
