#!/bin/bash
set -euo pipefail

INPUT=$(cat)

# Prevent infinite loop: if stop hook already fired, allow stop
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd')

# Only enforce in directories that use beads
if [ ! -d "$CWD/.beads" ]; then
  exit 0
fi

# Check if any code files were modified (staged, unstaged, or untracked)
CODE_CHANGES=$(cd "$CWD" && git diff --name-only 2>/dev/null | grep -E '\.(go|js|ts|py|sql|html|css)$|Dockerfile|docker-compose.*\.yml|Makefile' || true)
STAGED_CHANGES=$(cd "$CWD" && git diff --cached --name-only 2>/dev/null | grep -E '\.(go|js|ts|py|sql|html|css)$|Dockerfile|docker-compose.*\.yml|Makefile' || true)
UNTRACKED=$(cd "$CWD" && git ls-files --others --exclude-standard 2>/dev/null | grep -E '\.(go|js|ts|py|sql|html|css)$|Dockerfile|docker-compose.*\.yml|Makefile' || true)

ALL_CHANGES="${CODE_CHANGES}${STAGED_CHANGES}${UNTRACKED}"

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
