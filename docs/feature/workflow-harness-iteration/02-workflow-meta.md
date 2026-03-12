# 02: workflow-meta Skill

| Field | Value |
|-------|-------|
| Source | architecture.md, Component 2 |
| Depends on | — (independent) |
| Blocks | — |
| Estimated scope | S |

## Overview

An active skill for iterating on the workflow harness infrastructure — commands, skills, agents, and their interconnections. This is the formalized entry point for "I want to improve the workflow system itself," replacing the manual bootstrapping pattern of running `/workflow-start workflow-<name>`.

## Existing Code Context

- `home/.claude/skills/add-feature/SKILL.md` — closest template for skill structure. Uses `name` + `description` frontmatter, `## Usage`, `## Workflow` body with numbered steps.
- `home/.claude/skills/fix-issue/SKILL.md` — another skill template showing beads integration pattern (mandatory issue creation before code changes).
- `home/.claude/commands/workflow-*.md` — the harness files that this skill operates on. 11 workflow commands with `description` + `user_invocable: true` frontmatter.
- `home/.claude/agents/*.md` — agent definitions that this skill may need to modify.

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `home/.claude/skills/workflow-meta/SKILL.md` | Create | The skill file — single markdown file with frontmatter |

## Implementation Steps

### 1. Create the skill directory and file with exact frontmatter

```yaml
---
name: workflow-meta
description: Iterate on the workflow harness infrastructure — commands, skills, agents. Loads harness context, creates issues, implements changes, and verifies results.
---
```

### 2. Write the title and description

```markdown
# /workflow-meta

Iterate on the workflow harness infrastructure. Use this for targeted improvements to workflow commands, skills, or agents. For large, multi-session overhauls, use `/workflow-start workflow-<name>` instead.
```

### 3. Write the Usage section

```markdown
## Usage

```
/workflow-meta <description of what to improve>
```
```

### 4. Write the Workflow section

The workflow has 6 numbered steps:

#### Step 1: Load harness inventory

Scan all harness files in parallel using Explore agents:

```
Task(subagent_type="Explore", prompt="Scan the workflow harness inventory:
1. List all files in home/.claude/commands/ with their description from YAML frontmatter
2. List all files in home/.claude/skills/ with their name and description from YAML frontmatter
3. List all files in home/.claude/agents/ with their title
4. List all .workflows/*/state.json files with workflow name and current_phase
Return: inventory table with counts and file paths, plus active workflow summary.")
```

Present the inventory summary: "Found N commands, N skills, N agents, N active workflows."

#### Step 2: Validate harness health

Run quick consistency checks before making changes. Report issues but don't block on them unless they're relevant to the requested improvement.

Checks to run:
- **Command frontmatter**: Every `home/.claude/commands/workflow-*.md` has both `description` and `user_invocable: true` in its YAML frontmatter
- **Skill structure**: Every `home/.claude/skills/*/SKILL.md` has `name` and `description` in its YAML frontmatter
- **Workflow state integrity**: Each `.workflows/*/state.json` has:
  - Valid `current_phase` matching one of: research, plan, spec, decompose, implement
  - Phase statuses are one of: not_started, active, completed
  - `completed` phases have non-null `completed_at` and `handoff_prompt`
  - No phase after `current_phase` has status `active` or `completed`
- **Beads consistency**: Epic IDs in state.json (`beads_epic_id`) resolve when checked with `bd show <id>`. Gate IDs similarly resolve.
- **Artifact completeness**: Completed phases have their expected handoff prompt file on disk

Output: pass/fail per check. If all pass: "Harness is healthy." If failures: list them with file paths.

#### Step 3: Search for prior art

Check beads issues and git history for related past work:

```
bd search '<keywords from description>' --limit 10
```

For each relevant match, `bd show <id>` to get details. Also search dead-ends across workflows:

```
Grep for keywords in .workflows/*/research/dead-ends.md
```

Report: relevant prior issues, and any dead ends to avoid repeating.

#### Step 4: Break down the improvement

Create beads issues for each discrete change. **Do NOT write any code until all issues are created and the first one is claimed.**

- Create issues with `bd create --title="[Harness] <change>" --type=task --priority=2`
- Add `harness` label: `bd label add <id> harness`
- Set dependencies if changes must be ordered: `bd dep add <dependent-id> <blocker-id>`
- Claim the first unblocked issue: `bd update <id> --status=in_progress`

For single-file changes, one issue is sufficient. For changes touching multiple commands/skills, create one issue per file.

#### Step 5: Implement changes

Work through issues sequentially via `bd ready`:

- Claim the next unblocked task with `bd update <id> --status=in_progress`
- Edit or create the command/skill/agent file
- Follow established templates:
  - **Commands**: `description` + `user_invocable: true` frontmatter; `## Arguments`, `## Process`, `## Key principles` body
  - **Skills**: `name` + `description` frontmatter; `## Usage`, `## Workflow` body
  - **Agents**: `# Name — "Nickname"` header; `## Tools`, `## Review Focus`, `## Output Format` body
- After each change, read the modified file back to verify structure
- Close with `bd close <id> --reason="Implemented: <summary>"`

#### Step 6: Verify

After all issues are closed:

- Run `./validate.sh` to catch any regressions in shell scripts, configs, etc.
- Read back each modified file to confirm correct YAML frontmatter and markdown structure
- Close all remaining beads issues

### 5. Write the escalation guidance

Include this as a note after the workflow steps:

```markdown
**When to escalate to a full workflow**: If the improvement requires research into unfamiliar patterns, architectural decisions with multiple options, or changes spanning 5+ files, recommend `/workflow-start workflow-<name>` instead. workflow-meta is for targeted, single-session improvements where the path is clear.
```

### 6. Write the self-referential safeguard

Include this as a note:

```markdown
**Self-referential changes**: If asked to modify `workflow-meta` itself (this file), acknowledge the recursion, proceed with the edit, and suggest the user review the diff manually before committing. Do not skip the verification step.
```

## Acceptance Criteria

- [ ] File exists at `home/.claude/skills/workflow-meta/SKILL.md` with correct frontmatter (`name: workflow-meta`, `description`)
- [ ] Step 1 scans all three harness directories (commands, skills, agents) plus active workflows
- [ ] Step 2 validates command frontmatter, skill structure, workflow state integrity, beads consistency, and artifact completeness
- [ ] Step 3 searches beads issues and dead-ends for prior art before making changes
- [ ] Step 4 creates beads issues before any code changes (mandatory issue-first pattern from /add-feature and /fix-issue)
- [ ] Step 5 follows established templates for each file type (command, skill, agent)
- [ ] Step 6 runs `./validate.sh` and reads back modified files
- [ ] Escalation guidance included: recommends `/workflow-start` for large changes (5+ files or research needed)
- [ ] Self-referential safeguard included: handles the case where workflow-meta is asked to modify itself
- [ ] Skill is discoverable via Claude Code's automatic skill detection
