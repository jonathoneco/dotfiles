#!/usr/bin/env bash
set -euo pipefail

# Read JSON context from stdin
context=$(cat)
cwd=$(echo "$context" | jq -r '.cwd')

# Defer to project-level hook if it exists
if [ -f "$cwd/.claude/hooks/review-gate.sh" ]; then
  exit 0
fi

# Only run if .work/ exists with active tasks
if [ ! -d "$cwd/.work" ]; then
  exit 0
fi

# Check for active tasks (any state.json where archived_at is null)
active_task=false
for state_file in "$cwd"/.work/*/state.json; do
  [ -f "$state_file" ] || continue
  archived=$(jq -r '.archived_at // "null"' "$state_file")
  if [ "$archived" = "null" ]; then
    active_task=true
    break
  fi
done

if [ "$active_task" = "false" ]; then
  exit 0
fi

# Get session diff (staged + unstaged changes)
diff_output=$(cd "$cwd" && git diff HEAD 2>/dev/null || true)
if [ -z "$diff_output" ]; then
  exit 0
fi

# Anti-pattern grep patterns (critical findings that block)
critical_patterns=(
  '_, _ ='                    # Swallowed error return
  '_ = .*\.Exec\('            # Swallowed DB exec
  '_ = .*\.Render\('          # Swallowed template render
)

# Exclude test files from pattern matching (higher false positive rate)
diff_output=$(echo "$diff_output" | grep -v '_test.go' || true)

# Check diff for critical patterns
found_critical=false
findings=""

for pattern in "${critical_patterns[@]}"; do
  matches=$(echo "$diff_output" | grep -n "^+" | grep -E "$pattern" || true)
  if [ -n "$matches" ]; then
    found_critical=true
    findings="${findings}\n  - Pattern: ${pattern}\n    ${matches}"
  fi
done

if [ "$found_critical" = "true" ]; then
  echo "⚠ Review gate: potential anti-patterns detected in session diff:" >&2
  echo -e "$findings" >&2
  echo "" >&2
  echo "Fix these before ending the session, or run /work-review for full analysis." >&2
  exit 2  # Block session end
fi

exit 0
