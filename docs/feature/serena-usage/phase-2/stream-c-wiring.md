# Stream C: Wiring

| Field | Value |
|-------|-------|
| Work items | W-03, W-04 |
| Prerequisites | Stream A and Stream B complete |
| Estimated scope | S |
| Depends on | Stream A, Stream B |
| Blocks | -- |

## Existing Code Context
Read these files before starting:
- `home/.claude/settings.json` — Current hooks config. SessionStart hook at lines 83-92 has `>/dev/null 2>&1` suppression.
- `home/.claude/CLAUDE.md` — Current global instructions. ~100 lines, last section is "Shell & Scripting".
- `docs/feature/serena-usage/03-session-hook-update.md` — Spec for hook change
- `docs/feature/serena-usage/04-claude-md-section.md` — Spec for CLAUDE.md addition

## Internal Work Item Ordering

### Step 1: W-03 — Remove stdout suppression from SessionStart hook

In `home/.claude/settings.json`, change the SessionStart hook command from:
```
serena-ensure "$PWD" >/dev/null 2>&1 || true
```
To:
```
serena-ensure "$PWD" 2>/dev/null || true
```

This removes stdout suppression (so activation context reaches Claude) while keeping stderr suppressed and graceful failure.

Verify JSON validity after edit:
```bash
python3 -c "import json; json.load(open('home/.claude/settings.json'))"
```

- [ ] Acceptance: Hook command is `serena-ensure "$PWD" 2>/dev/null || true`
- [ ] Acceptance: `settings.json` is valid JSON
- [ ] Acceptance: stderr still suppressed

### Step 2: W-04 — Add Serena section to CLAUDE.md

Append after the "Shell & Scripting" section at the end of `home/.claude/CLAUDE.md`:

```markdown

## Serena

Serena MCP tools provide LSP-backed semantic code navigation. When available:
- Run `/serena-activate` at session start (auto-triggered by SessionStart hook)
- After context compaction, re-run `/serena-activate` to restore Serena guidance
- Prefer `find_symbol`, `find_referencing_symbols`, `get_symbols_overview` over reading entire files
- Use `rename_symbol` for cross-file renames (no Claude Code equivalent)
- Use `get_symbols_overview` before reading a file to understand its structure first
```

- [ ] Acceptance: Serena section present after "Shell & Scripting"
- [ ] Acceptance: References `/serena-activate`
- [ ] Acceptance: Includes compaction recovery instruction
- [ ] Acceptance: Section is ≤8 lines

## Key Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|
| `home/.claude/settings.json` | Modify | Change hook command (one line) |
| `home/.claude/CLAUDE.md` | Modify | Append Serena section (~7 lines) |

## Interface Contracts

### Exposes
- SessionStart hook delivers `serena-ensure` stdout to Claude as session context
- CLAUDE.md provides persistent Serena guidance across all sessions

### Consumes
- `serena-ensure` stdout output format (from Stream A)
- `/serena-activate` skill name (from Stream B)

## Risk Notes
- The hook change is a one-character edit but has high impact — if malformed, Claude Code sessions won't start cleanly
- CLAUDE.md is stowed to `~/.claude/CLAUDE.md` — changes take effect after `stow home`

## Merge Gate Checklist

### Build verification
- [ ] `python3 -c "import json; json.load(open('home/.claude/settings.json'))"` passes
- [ ] `./validate.sh` passes

### Runtime verification
- [ ] Start fresh Claude Code session → Claude receives "Serena MCP server active..." context
- [ ] Claude invokes `/serena-activate` in response to hook context
- [ ] After activation, ask Claude to find a function → uses `find_symbol`
- [ ] Check Serena dashboard → tool usage stats are no longer empty

### Issue closure
- [ ] W-03 beads issue closed
- [ ] W-04 beads issue closed

### Artifacts produced
- [ ] Modified `home/.claude/settings.json`
- [ ] Modified `home/.claude/CLAUDE.md`

## Implementation Prompt
> You are implementing Stream C (Wiring) of the serena-usage workflow.
>
> **Read first**: `docs/feature/serena-usage/03-session-hook-update.md`, `docs/feature/serena-usage/04-claude-md-section.md`, `home/.claude/settings.json`, `home/.claude/CLAUDE.md`
> **Execute in order**: (1) Change SessionStart hook command to remove stdout suppression, (2) Append Serena section to CLAUDE.md
> **Verify**: JSON validity check + `./validate.sh`
> **Beads**: `bd update <issue-id> --status=in_progress` before starting, `bd close <issue-id>` when done
