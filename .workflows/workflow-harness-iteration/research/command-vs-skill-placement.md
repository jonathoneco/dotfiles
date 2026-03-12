# Research: Command vs Skill Placement

## Key Findings

- **Both should be COMMANDS** (in `home/.claude/commands/`), not skills
- Commands = orchestration/guidance utilities; Skills = complete task methodologies
- Filesystem structure is the registry — no manifest needed

## Structural Differences

| Aspect | Commands | Skills |
|--------|----------|--------|
| Location | `home/.claude/commands/<slug>.md` | `home/.claude/skills/<slug>/SKILL.md` |
| Frontmatter | `description`, `user_invocable: true` | `name`, `description` |
| Structure | Flat file | Nested directory (can have supporting files) |
| Discovery | Automatic by path | Automatic by path |

## Semantic Differences

| Aspect | Commands | Skills |
|--------|----------|--------|
| Purpose | Guide user through phases, state management, evaluation | Complete task end-to-end (feature, fix, review) |
| Output | State transitions, user guidance, directories | Implemented code, closed issues, review reports |
| Duration | Point-in-time invocation | Extended workflow from start to finish |
| Examples | workflow-status, adversarial-eval, ama | add-feature, fix-issue, review |

## Recommendation

**`workflow-help`** → `home/.claude/commands/workflow-help.md`
- Rationale: Guidance utility, not a task completion method. Similar to `/ama` (answers questions) and `/workflow-status` (inspects state).

**`workflow-meta`** → `home/.claude/commands/workflow-meta.md`
- Rationale: Harness introspection utility. Operates on workflow state and command files. Similar to `/workflow-status` in purpose (inspect and report).

## Implications for Design
- Use `description` + `user_invocable: true` frontmatter
- Follow `## Arguments` + `## Process` + `## Key principles` body structure
- Both integrate naturally with the `workflow-*` command family namespace
