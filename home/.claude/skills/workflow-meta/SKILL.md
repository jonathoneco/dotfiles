---
name: workflow-meta
description: Iterate on the work harness infrastructure — commands, skills, agents, hooks. Loads harness context, creates issues, implements changes, and verifies results.
---

# /workflow-meta

Iterate on the work harness infrastructure. Use this for targeted improvements to work commands, skills, agents, or hooks. For large, multi-session overhauls, use `/work-deep` instead.

## Usage

```
/workflow-meta <description of what to improve>
```

## Workflow

1. **Load harness inventory**: Scan all harness files in parallel using Explore agents:
   ```
   Agent(subagent_type="Explore", prompt="Scan the work harness inventory:
   1. List all files in home/.claude/commands/work*.md with their description from YAML frontmatter
   2. List all files in home/.claude/skills/ with their name and description from YAML frontmatter
   3. List all files in home/.claude/agents/ with their title
   4. List all files in home/.claude/hooks/ with their purpose
   5. List any .work/*/state.json files with task name and current_step
   Return: inventory table with counts and file paths, plus active task summary.")
   ```

   Present the inventory summary: "Found N commands, N skills, N agents, N hooks, N active tasks."

2. **Validate harness health**: Run quick consistency checks before making changes.

   Checks to run:
   - **Command frontmatter**: Every `home/.claude/commands/work*.md` has both `description` and `user_invocable: true` in its YAML frontmatter
   - **Skill structure**: Every `home/.claude/skills/*/SKILL.md` has `name` and `description` in its YAML frontmatter
   - **Task state integrity**: Each `.work/*/state.json` has:
     - Valid `current_step` matching one of the entries in `steps` array
     - Step statuses are one of: not_started, active, completed, skipped
     - Only one step is `active` at a time
     - `completed` steps have non-null `completed_at`
   - **Hook health**: All three Stop hooks exist and are executable: `work-check.sh`, `beads-check.sh`, `review-gate.sh`
   - **Beads consistency**: Issue IDs in state.json resolve with `bd show`

   Output: pass/fail per check. If all pass: "Harness is healthy."

3. **Search for prior art**: Check beads issues and git history for related past work:
   ```
   bd search '<keywords from description>' --limit 10
   ```

   Also search dead-ends across tasks:
   ```
   Grep for keywords in .work/*/dead-ends.md
   ```

4. **Break down the improvement**: Create beads issues for each discrete change. **Do NOT write any code until all issues are created and the first one is claimed.**

   - Create issues with `bd create --title="[Harness] <change>" --type=task --priority=2`
   - Add `harness` label: `bd label add <id> harness`
   - Set dependencies if changes must be ordered
   - Claim the first unblocked issue: `bd update <id> --status=in_progress`

5. **Implement changes**: Work through issues sequentially via `bd ready`:

   - Claim the next unblocked task
   - Edit or create the command/skill/agent/hook file
   - Follow established templates:
     - **Commands**: `description` + `user_invocable: true` frontmatter; detect active task, step router, skill propagation
     - **Skills**: `name` + `description` frontmatter; `SKILL.md` + `references/` directory
     - **Agents**: `# Name — "Nickname"` header; `## Tools`, `## Review Focus/Priorities`, `## Output Format` (structured findings format)
     - **Hooks**: `#!/usr/bin/env bash`, `set -euo pipefail`, read JSON from stdin, exit 0 (pass) or exit 2 (block)
   - Close with `bd close <id> --reason="Implemented: <summary>"`

6. **Verify**: After all issues are closed:

   - Read back each modified file to confirm correct structure
   - Run `shellcheck` on any modified hook scripts
   - Close all remaining beads issues

**When to escalate**: If the improvement requires research, architectural decisions with multiple options, or changes spanning 5+ files, recommend `/work-deep` instead. workflow-meta is for targeted, single-session improvements where the path is clear.

**Self-referential changes**: If asked to modify `workflow-meta` itself (this file), acknowledge the recursion, proceed with the edit, and suggest the user review the diff manually.
