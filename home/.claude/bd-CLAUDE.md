<!-- bv-agent-instructions-v1 -->

---

## Beads Workflow Integration

This project uses [beads_viewer](https://github.com/Dicklesworthstone/beads_viewer) for issue tracking. Issues are stored in `.beads/` and tracked in git.

### 🚨 BEFORE STARTING ANY WORK 🚨

**Always run these commands first:**

```bash
bd ready              # Check for existing work to pick up
bd list --status=open # See all open issues
```

If the user's request matches an existing issue, **claim it** before working:

```bash
bd update <id> --status=in_progress
```

If no matching issue exists, **create one first**:

```bash
bd create --title="User's request summary" --type=task|bug|feature --priority=2
bd update <id> --status=in_progress
```

## ⛔ NEVER EDIT CODE WITHOUT A BEADS ISSUE ⛔

**No exceptions.** Even for:

- "Simple" one-line changes
- "Quick" config updates
- "Obvious" bug fixes
- User-provided code to paste in

**The workflow is:**

1. Check existing issues
2. Create issue if none exists
3. Claim the issue (`--status=in_progress`)
4. THEN edit code
5. Close issue when done

**If you find yourself about to edit a file without an in_progress issue, STOP and create one first.**

### 🔍 GATHER CONTEXT FROM CLOSED ISSUES 🔍

**MANDATORY: Check closed issues BEFORE reading code or using Explore agents.**

Closed issues are your primary source of truth - they document exactly what was built and where. Do NOT skip this step.

**IMPORTANT: Always use a sub-agent to gather beads context.** Do NOT run `bd list`, `bd show`, or `bd search` commands directly in the main session - this wastes context window on potentially irrelevant details. Instead, delegate to a Task sub-agent that searches, reads, and returns only a concise summary.

```
Task(subagent_type="Explore", prompt="Search closed beads issues for context about <topic>.
Run: bd list --status=closed | grep -i <keyword1>, grep -i <keyword2>, etc.
Then run bd show <id> for each relevant match.
Return a concise summary with:
- Which files are relevant and why
- What patterns/approaches were used
- Any key decisions or gotchas
Do NOT return raw issue output - summarize what matters for implementing <topic>.")
```

**Example:** For "fix chat session bugs":

```
Task(subagent_type="Explore", prompt="Search closed beads issues for context about chat sessions.
Run: bd list --status=closed | grep -i session
Run: bd list --status=closed | grep -i chat
Then bd show each relevant match.
Summarize: which files handle sessions/chat, what patterns are used, any recent related changes.")
```

**What the sub-agent should extract from closed issues:**

- **Files** - exactly which files to look at
- **Problem/Solution** - what was done and why
- **Dependencies** - what this feature built on
- **Close reasons** - summary of implementation

**Only AFTER reviewing the sub-agent's summary**, if you still need more detail:

- Use Explore agent for tracing code paths across files
- Use Read tool for specific files mentioned in the summary

This order matters: **beads context sub-agent → code exploration → implementation**

### Essential Commands

```bash
# View issues (launches TUI - avoid in automated sessions)
bv

# CLI commands for agents (use these instead)
bd ready              # Show issues ready to work (no blockers)
bd list --status=open # All open issues
bd show <id>          # Full issue details with dependencies
bd create --title="..." --type=task --priority=2
bd update <id> --status=in_progress
bd close <id> --reason="Completed"
bd close <id1> <id2>  # Close multiple issues at once
bd sync               # Commit and push changes
```

### Workflow Pattern

**Every task follows this flow - no exceptions:**

1. **Check**: Run `bd ready` and `bd list --status=open` to find existing work
2. **Context**: Check closed issues for related implementation details
3. **Plan**: For complex work, break into multiple tagged issues with dependencies
4. **Claim**: Use `bd update <id> --status=in_progress` before coding
5. **Work**: Implement one issue at a time
6. **Complete**: Use `bd close <id> --reason="what was done"`
7. **Repeat**: Run `bd ready` to get next unblocked issue
8. **Sync**: Always run `bd sync --flush-only` at session end

**Example for user request "Add delete button for documents":**

```bash
# 1. Check existing work
bd ready
bd list --status=open
```

```
# 2. Gather context from closed issues (via sub-agent)
Task(subagent_type="Explore", prompt="Search closed beads issues for context about document management.
Run: bd list --status=closed | grep -i document
Then bd show each relevant match.
Summarize: which files handle documents, upload patterns, UI location, any delete-related work.")
```

```bash
# 3. Plan and create work items
bd create --title="[Service] Add cascade delete for documents" --type=task --priority=2
bd create --title="[API] Add DELETE /documents/{id} endpoint" --type=task --priority=2
bd create --title="[UX] Add delete button to document list" --type=task --priority=2
bd dep add <project>-api <project>-service
bd dep add <project>-ux <project>-api

# 4. Work through issues sequentially
bd ready                          # Shows service task
bd update <project>-service --status=in_progress
# ... implement service layer ...
bd close <project>-service --reason="Added DeleteWithCascade to DocumentService"

bd ready                          # Shows API task (now unblocked)
# ... continue ...
```

### 📋 PLANNING COMPLEX WORK 📋

**For non-trivial requests, plan before coding:**

1. **Gather context** from closed issues (via sub-agent - never in main session)
2. **Break down** into discrete work items
3. **Create issues** with proper tags and dependencies
4. **Work sequentially**, closing each issue as you go

**Title Tags** - Use prefixes to categorize work:

_Parent work types (for feature issues):_

- `[CRUD]` - Full create/read/update/delete operation (API + Service + UX)
- `[Feature]` - New user-facing capability
- `[Workflow]` - Multi-step process or flow
- `[Integration]` - External service connection

_Layer-specific (for subtasks):_

- `[API]` - Backend endpoint changes
- `[UX]` - Frontend/template changes
- `[DB]` - Database schema or queries
- `[Service]` - Business logic layer
- `[Bug]` - Defect fix
- `[Refactor]` - Code improvement without behavior change

**Example: "Add delete button for documents"**

After gathering context via sub-agent, break into work items:

```bash
# Create parent feature with work type tag
bd create --title="[CRUD] Document deletion" --type=feature --priority=2 \
  --description="Add ability to delete documents from the UI.
Requires: Service cascade delete, API endpoint, UX button.
Context: See <project>-7g4 (upload), <project>-dfb (document UI)"

# Create subtasks with layer tags
bd create --title="[Service] Cascade delete for document data" --type=task --priority=2
bd create --title="[API] DELETE /api/v1/documents/{id} endpoint" --type=task --priority=2
bd create --title="[UX] Delete button on document list" --type=task --priority=2

# Link dependencies (UX depends on API, API depends on Service)
bd dep add <project>-api <project>-service    # API blocked by Service
bd dep add <project>-ux <project>-api         # UX blocked by API
```

**Work sequentially:**

```bash
bd ready                              # Shows <project>-service (unblocked)
bd update <project>-service --status=in_progress
# ... implement ...
bd close <project>-service --reason="Added DocumentService.DeleteWithCascade()"

bd ready                              # Now shows <project>-api
bd update <project>-api --status=in_progress
# ... implement ...
bd close <project>-api --reason="Added DELETE handler with ownership check"

bd ready                              # Now shows <project>-ux
# ... and so on
```

**When to break down work:**

- Request touches multiple layers (API + UX + DB)
- Multiple files need coordinated changes
- Work could be picked up by different sessions
- You want clear progress visibility

### Key Concepts

- **Dependencies**: Issues can block other issues. `bd ready` shows only unblocked work.
- **Priority**: P0=critical, P1=high, P2=medium, P3=low, P4=backlog (use numbers, not words)
- **Types**: task, bug, feature, epic, question, docs
- **Blocking**: `bd dep add <issue> <depends-on>` to add dependencies

### Git Worktree Protocol (Parallel Sessions)

This project uses **git worktrees** to run multiple Claude sessions in parallel without conflicts. Each worktree is a separate checkout on its own branch, sharing the same git history.

**Worktree layout:**

```
~/src/<project>        ← main worktree (main branch)
~/src/<project>-<name> ← additional worktrees (feature branches)
```

**At session start, identify your worktree:**

```bash
git worktree list          # See all active worktrees
git branch --show-current  # Which branch am I on?
pwd                        # Which worktree directory am I in?
```

**Rules:**

- **NEVER switch branches** — your worktree is locked to its branch
- **NEVER run `git worktree add/remove`** — the user manages worktrees manually
- **Claim a beads issue immediately** — this prevents another worktree from picking up the same work
- **Run `bd sync` frequently** — this makes your issue claims visible to other sessions
- **Pull before starting** — run `git pull` to see issue claims from other worktrees

**Coordination via beads:**

Beads issues are the coordination mechanism between worktrees. When you claim an issue with `bd update <id> --status=in_progress` and sync, other worktrees can see it's taken.

```bash
# At session start in any worktree:
git pull                   # Get latest beads state from other worktrees
bd ready                   # See unclaimed work
bd list --status=in_progress  # See what other sessions are working on
```

**Avoiding conflicts:**

- Each worktree should work on **separate files/features** when possible
- If two worktrees must touch the same area, coordinate via beads issue descriptions
- Merge conflicts in `.beads/` are resolved by git — individual issue files rarely conflict
- Commit and push frequently to minimize divergence

**Merging back to main:**

- The user handles merging worktree branches back to main
- NEVER merge other branches or rebase — the user manages branch integration

### Session Protocol

**Before ending any session, run this checklist:**

```bash
git status              # Check what changed
git add <files>         # Stage code changes
bd sync                 # Commit beads changes
git commit -m "..."     # Commit code
bd sync                 # Commit any new beads changes
git push                # Push to remote
```

### Best Practices

- **First action on any request**: Run `bd ready` and `bd list --status=open`
- **EVERY code change needs an issue** - no matter how "simple" it seems
- **Claim before editing**: `bd update <id> --status=in_progress` BEFORE any file edits
- Update status as you work (in_progress → closed)
- Create new issues with `bd create` when you discover tasks
- Use descriptive titles and set appropriate priority/type
- Always `bd sync --flush-only` before ending session

### Writing Good Issue Context

**Always add descriptions** so future sessions can pick up quickly:

```bash
# When creating
bd create --title="Fix NULL scanning" --type=bug --priority=1 \
  --description="Problem: pgx can't scan NULL into string fields.
Solution: Add COALESCE() to queries.
Files: internal/services/documents.go"

# When closing
bd close <id> --reason="Added COALESCE for nullable fields in all queries"

# To add description later
bd update <id> --description="..."
```

**Description format:**

```
Problem: What broke or what's needed
Solution: What was implemented
Files: Key files modified
```

This context helps future sessions understand:

- Why the issue exists
- What approach was taken
- Where to look in the codebase

### Gathering Context for New Features

**Order matters - follow this sequence:**

**1. FIRST: Search closed issues via sub-agent (mandatory)**

```
Task(subagent_type="Explore", prompt="Search closed beads issues for context about <topic>.
Run: bd list --status=closed | grep -i <keyword>
Then bd show each relevant match.
Return a concise summary: relevant files, patterns used, key decisions, gotchas.")
```

This keeps raw issue output out of the main session and returns only what matters.

**2. THEN: Read specific files mentioned in the summary**

```bash
Read(file_path="internal/handlers/sessions.go")  # Files from sub-agent summary
```

**3. ONLY IF NEEDED: Use Explore agents for deeper understanding**

```
# Trace complex flows across multiple files
Task(subagent_type="Explore", prompt="Trace the message sending flow from handler through LLM to response")

# Plan implementation strategy
Task(subagent_type="Plan", prompt="Plan implementation for adding email notifications on document ready")
```

**When to use additional Explore agents:**

- Tracing code paths across 5+ files
- Understanding complex interactions not covered by closed issues
- Finding all usages of a pattern

**When NOT to use additional Explore agents:**

- When the beads context sub-agent already identified the relevant files
- When you just need to read 2-3 known files

**Context gathering checklist:**

1. ✅ Search closed issues via sub-agent (NOT in main session)
2. ✅ Review the sub-agent's summary
3. ✅ Read the specific files mentioned in the summary
4. ⚠️ Only then use Explore agents if gaps remain
5. ✅ Update issue description with findings if needed

<!-- end-bv-agent-instructions -->
