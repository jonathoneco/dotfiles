# 04: CLAUDE.md Serena Section

| Field | Value |
|-------|-------|
| Source | architecture.md, C3 |
| Depends on | 02-serena-activate-skill |
| Blocks | -- |
| Estimated scope | S |

## Overview

Add a minimal Serena section to the global `home/.claude/CLAUDE.md` that provides persistent guidance surviving context compaction. Points to the `/serena-activate` skill for details rather than duplicating instructions.

## Existing Code Context

- `home/.claude/CLAUDE.md` — ~100 lines, organized by topic sections: System, Git, Claude Code Behavior, Proactive Agent Usage, Context Gathering & Management, Automatic Team Orchestration, Go Conventions, Shell & Scripting.
- This file is stowed to `~/.claude/CLAUDE.md` and applies to ALL projects.
- The file is always loaded into conversation context by Claude Code.

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `home/.claude/CLAUDE.md` | Modify | Add Serena section after "Shell & Scripting" |

## Implementation Steps

### 1. Append Serena section

Add the following after the "Shell & Scripting" section at the end of the file:

```markdown

## Serena

Serena MCP tools provide LSP-backed semantic code navigation. When available:
- Run `/serena-activate` at session start (auto-triggered by SessionStart hook)
- After context compaction, re-run `/serena-activate` to restore Serena guidance
- Prefer `find_symbol`, `find_referencing_symbols`, `get_symbols_overview` over reading entire files
- Use `rename_symbol` for cross-file renames (no Claude Code equivalent)
- Use `get_symbols_overview` before reading a file to understand its structure first
```

### 2. Verify the section integrates cleanly

The section should:
- Be self-contained — readable without the skill loaded
- Not duplicate the full tool guidance table from the skill (that's the skill's job)
- Include the compaction recovery instruction (key value of CLAUDE.md persistence)

## Interface Contracts

### Exposes
- Persistent Serena guidance in every Claude Code session context

### Consumes
- `/serena-activate` skill (from spec 02) — referenced by name

## Testing Strategy

- Read the file to verify formatting and placement
- Start a new Claude Code session and confirm the Serena section appears in context
- Test context compaction scenario: after compaction, verify Claude still knows to use Serena tools from CLAUDE.md

## Acceptance Criteria

- [ ] Serena section added after "Shell & Scripting" in `home/.claude/CLAUDE.md`
- [ ] References `/serena-activate` skill
- [ ] Includes compaction recovery instruction
- [ ] Lists the 4-5 key tool preferences (not the full table — that's in the skill)
- [ ] Section is ≤8 lines (minimal, not duplicating skill content)
