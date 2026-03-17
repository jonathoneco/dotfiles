#!/bin/bash
set -euo pipefail

INPUT=$(cat)

# Prevent infinite loop
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd')

if [ ! -d "$CWD/.work" ]; then
  exit 0
fi

for state_file in "$CWD"/.work/*/state.json; do
  [ -f "$state_file" ] || continue

  tier=$(jq -r '.tier' "$state_file")
  [ "$tier" -ge 2 ] 2>/dev/null || continue

  task_name=$(jq -r '.name' "$state_file")

  # Skip legacy format (steps as string array, not object array)
  steps_type=$(jq -r '.steps[0] | type' "$state_file" 2>/dev/null)
  if [ "$steps_type" = "string" ]; then
    continue
  fi

  # Check 1: Archived Tier 2-3 must have review evidence
  # Only enforce for tasks that have the reviewed_at field (even if null)
  # Tasks without the field predate this enforcement
  archived=$(jq -r '.archived_at // "null"' "$state_file")
  if [ "$archived" != "null" ]; then
    has_field=$(jq 'has("reviewed_at")' "$state_file")
    if [ "$has_field" = "true" ]; then
      reviewed=$(jq -r '.reviewed_at // "null"' "$state_file")
      if [ "$reviewed" = "null" ]; then
        echo "Review verify: task '$task_name' is archived but review was never run" >&2
        echo "Run /work-review before archiving." >&2
        exit 2
      fi
    fi
  fi

  # Check 2: Review step marked completed must have evidence
  review_status=$(jq -r '(.steps[] | select(.name == "review") | .status) // "not_started"' "$state_file")
  if [ "$review_status" = "completed" ]; then
    reviewed=$(jq -r '.reviewed_at // "null"' "$state_file")
    if [ "$reviewed" = "null" ]; then
      echo "Review verify: task '$task_name' review step is 'completed' but reviewed_at is not set" >&2
      echo "Run /work-review to set the reviewed_at timestamp." >&2
      exit 2
    fi
  fi
done

exit 0
