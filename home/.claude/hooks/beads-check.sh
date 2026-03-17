#!/bin/bash
set -euo pipefail

INPUT=$(cat)

# Prevent infinite loop: if stop hook already fired, allow stop
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd')

# Defer to project-level hook if it exists
if [ -f "$CWD/.claude/hooks/beads-check.sh" ]; then
  exit 0
fi

# Only enforce in directories that use beads
if [ ! -d "$CWD/.beads" ]; then
  exit 0
fi

# Only check staged changes — unstaged/untracked may be pre-existing dirty state
ALL_CHANGES=$(cd "$CWD" && git diff --cached --name-only 2>/dev/null | grep -E '\.(go|js|ts|py|sql|html|css)$|Dockerfile|docker-compose.*\.yml|Makefile' || true)

# Exclude work harness state files from "code modified" detection
ALL_CHANGES=$(echo "$ALL_CHANGES" | grep -v '^\.work/' || true)

# No code changes? Allow stop
if [ -z "$ALL_CHANGES" ]; then
  exit 0
fi

# Code was changed — check for an in_progress beads issue
IN_PROGRESS=$(cd "$CWD" && bd list --status=in_progress 2>/dev/null || true)
if [ -n "$IN_PROGRESS" ]; then
  exit 0
fi

# Block: code changes without a claimed issue
echo "Code files modified but no beads issue claimed. Run: bd ready && bd update <id> --status=in_progress" >&2
exit 2
