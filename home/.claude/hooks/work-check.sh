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
if [ -f "$CWD/.claude/hooks/work-check.sh" ]; then
  exit 0
fi

# Only check in projects with active work tasks
if [ ! -d "$CWD/.work" ]; then
  exit 0
fi

# Check for active Tier 2-3 tasks without checkpoints
for state_file in "$CWD"/.work/*/state.json; do
  [ -f "$state_file" ] || continue
  archived=$(jq -r '.archived_at // "null"' "$state_file")
  [ "$archived" = "null" ] || continue

  tier=$(jq -r '.tier' "$state_file")

  # Only warn for Tier 2-3 (Tier 1 is single-session)
  [ "$tier" -ge 2 ] 2>/dev/null || continue

  task_dir=$(dirname "$state_file")
  task_name=$(jq -r '.name' "$state_file")

  # Find any checkpoint files
  has_checkpoint=$(find "$task_dir" -path '*/checkpoints/*.md' 2>/dev/null | head -1)

  if [ -z "$has_checkpoint" ]; then
    echo "Note: Task '$task_name' (Tier $tier) has no checkpoints. Consider running /work-checkpoint before ending." >&2
  fi
done

exit 0  # Always non-blocking
