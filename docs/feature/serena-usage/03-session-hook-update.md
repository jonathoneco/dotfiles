# 03: Session Hook Update

| Field | Value |
|-------|-------|
| Source | architecture.md, C2 |
| Depends on | 01-serena-ensure-auto-detection, 02-serena-activate-skill |
| Blocks | 04-claude-md-section |
| Estimated scope | S |

## Overview

Remove stdout suppression from the SessionStart hook so Claude Code receives the activation context output by `serena-ensure`. This is the single change that connects the server startup (already working) to the skill invocation (spec 02).

## Existing Code Context

- `home/.claude/settings.json` lines 83-92 — SessionStart hook configuration:
  ```json
  "SessionStart": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "serena-ensure \"$PWD\" >/dev/null 2>&1 || true"
        }
      ]
    }
  ]
  ```
- The `>/dev/null 2>&1` suppresses ALL output. After spec 01, `serena-ensure` outputs structured activation context to stdout.
- The `|| true` ensures Claude Code starts even if Serena fails — this must be preserved.

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `home/.claude/settings.json` | Modify | Remove stdout suppression from SessionStart hook command |

## Implementation Steps

### 1. Update the SessionStart hook command

Change the command from:
```
serena-ensure "$PWD" >/dev/null 2>&1 || true
```

To:
```
serena-ensure "$PWD" 2>/dev/null || true
```

This change:
- **Keeps stderr suppression** (`2>/dev/null`) — error messages from curl, jq, etc. don't reach Claude
- **Removes stdout suppression** — the activation context from `serena-ensure` reaches Claude as session context
- **Keeps `|| true`** — Serena failure doesn't block session start

### 2. Verify JSON validity

After editing `settings.json`, verify the JSON is valid:
```bash
python3 -c "import json; json.load(open('home/.claude/settings.json'))"
```

## Interface Contracts

### Exposes
- SessionStart hook output becomes Claude Code session context
- Output format defined in `00-cross-cutting-contracts.md`

### Consumes
- `serena-ensure` stdout output (from spec 01)
- `/serena-activate` skill (from spec 02) — referenced in the output text

## Testing Strategy

1. Start a new Claude Code session
2. Verify Claude receives activation context (should mention "Serena MCP server active" in session)
3. Verify Claude invokes `/serena-activate` in response to the context
4. Verify that if `serena-ensure` fails, the session still starts normally (no error shown)

## Acceptance Criteria

- [ ] SessionStart hook command is `serena-ensure "$PWD" 2>/dev/null || true`
- [ ] stdout from `serena-ensure` reaches Claude as session context
- [ ] stderr is still suppressed
- [ ] Session starts normally when Serena server fails to start
- [ ] `settings.json` remains valid JSON
