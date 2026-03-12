# Stream B: Serena Activate Skill

| Field | Value |
|-------|-------|
| Work items | W-02 |
| Prerequisites | -- |
| Estimated scope | M |
| Depends on | -- |
| Blocks | Stream C |

## Existing Code Context
Read these files before starting:
- `home/.claude/skills/fix-issue/SKILL.md` — Reference for skill file format (YAML frontmatter + markdown body)
- `docs/feature/serena-usage/00-cross-cutting-contracts.md` — MCP tool call sequence and valuable tools reference
- `docs/feature/serena-usage/02-serena-activate-skill.md` — Full spec with complete skill content

## Internal Work Item Ordering

### Step 1: W-02 — Create serena-activate skill

1. **Create directory**: `home/.claude/skills/serena-activate/`

2. **Write `SKILL.md`** with:
   - YAML frontmatter: `name: serena-activate`, `description: Initialize Serena LSP tools...`
   - `## Usage` section: `/serena-activate`
   - `## Workflow` section (3 steps):
     1. Call `mcp__serena__check_onboarding_performed` — if not performed, call `mcp__serena__onboarding`
     2. Call `mcp__serena__initial_instructions` — load Serena's system prompt
     3. Report activation status briefly
   - `## When to Use Serena Tools` table: find_symbol, find_referencing_symbols, get_symbols_overview, replace_symbol_body, insert_before/after_symbol, rename_symbol
   - `## When NOT to Use Serena Tools` section: keep using Read, Grep, Glob, Write, Bash
   - `## Graceful Failure` section: fall back to builtins, suggest `serena-status`

- [ ] Acceptance: Skill file exists at `home/.claude/skills/serena-activate/SKILL.md`
- [ ] Acceptance: YAML frontmatter has correct `name` and `description`
- [ ] Acceptance: Workflow calls `check_onboarding_performed` before `initial_instructions`
- [ ] Acceptance: "When to Use" table covers all 6 valuable Serena tools
- [ ] Acceptance: Graceful failure section handles missing Serena

## Key Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|
| `home/.claude/skills/serena-activate/SKILL.md` | Create | Activation skill with tool guidance |

## Interface Contracts

### Exposes
- `/serena-activate` slash command — referenced by hook output (Stream A) and CLAUDE.md (Stream C)
- Tool preference guidance (the "When to Use" table)

### Consumes
- MCP tools: `mcp__serena__check_onboarding_performed`, `mcp__serena__onboarding`, `mcp__serena__initial_instructions`
- Valuable tools list from `00-cross-cutting-contracts.md`

## Risk Notes
- Skill auto-invocation reliability is untested — Claude may not consistently invoke `/serena-activate` from hook context. Will need manual testing.
- The `mcp__serena__` prefix is the Claude Code convention for MCP tools but may vary if Serena's server name changes in `.mcp.json`

## Merge Gate Checklist

### Build verification
- [ ] `./validate.sh` passes

### Runtime verification
- [ ] `/serena-activate` appears in Claude Code's available skills list
- [ ] Invoking `/serena-activate` calls `check_onboarding_performed` then `initial_instructions`
- [ ] After activation, Claude uses `find_symbol` when asked to find a function

### Issue closure
- [ ] W-02 beads issue closed

### Artifacts produced
- [ ] `home/.claude/skills/serena-activate/SKILL.md`

## Implementation Prompt
> You are implementing Stream B (Serena Activate Skill) of the serena-usage workflow.
>
> **Read first**: `docs/feature/serena-usage/00-cross-cutting-contracts.md`, `docs/feature/serena-usage/02-serena-activate-skill.md`, `home/.claude/skills/fix-issue/SKILL.md` (format reference)
> **Execute**: Create `home/.claude/skills/serena-activate/SKILL.md` with the full skill content from spec 02
> **Verify**: `./validate.sh`
> **Beads**: `bd update <issue-id> --status=in_progress` before starting, `bd close <issue-id>` when done
