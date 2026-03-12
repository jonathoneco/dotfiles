# Phase 2: Wiring

| Field | Value |
|-------|-------|
| Prerequisites | Phase 1 complete |
| Streams | 1 sequential stream |
| Work items | W-03, W-04 |

## Work Items

### W-03: Remove stdout suppression from SessionStart hook
- **Source**: 03-session-hook-update.md
- **Depends on**: W-01, W-02
- **Deliverable**: Modified `home/.claude/settings.json` hook command
- **Estimated scope**: S

### W-04: Add Serena section to CLAUDE.md
- **Source**: 04-claude-md-section.md
- **Depends on**: W-02
- **Deliverable**: ~5 lines appended to `home/.claude/CLAUDE.md`
- **Estimated scope**: S

## Phase Gate
- [ ] W-03 and W-04 completed
- [ ] `settings.json` is valid JSON
- [ ] `./validate.sh` passes
- [ ] Fresh Claude Code session receives Serena activation context
- [ ] Claude invokes `/serena-activate` in response
- [ ] Serena dashboard shows tool usage stats
