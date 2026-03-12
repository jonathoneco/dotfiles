#!/bin/bash
set -euo pipefail

INPUT=$(cat)

# Prevent infinite loop: if stop hook already fired, allow stop
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd')

# Only check in projects with active workflows
if [ ! -d "$CWD/.workflows" ]; then
  exit 0
fi

# Check if any workflow files were modified (staged or unstaged)
WORKFLOW_CHANGES=$(cd "$CWD" && git diff --name-only 2>/dev/null | grep -E '^\.workflows/' || true)
STAGED_WORKFLOW=$(cd "$CWD" && git diff --cached --name-only 2>/dev/null | grep -E '^\.workflows/' || true)
UNTRACKED_WORKFLOW=$(cd "$CWD" && git ls-files --others --exclude-standard 2>/dev/null | grep -E '^\.workflows/' || true)

ALL_WORKFLOW_CHANGES="${WORKFLOW_CHANGES}${STAGED_WORKFLOW}${UNTRACKED_WORKFLOW}"

# No workflow changes? Allow stop
if [ -z "$ALL_WORKFLOW_CHANGES" ]; then
  exit 0
fi

# Check if the most recent change includes a checkpoint
# Look for checkpoint files modified in the last few minutes
RECENT_CHECKPOINTS=$(cd "$CWD" && find .workflows/*/research/checkpoints/ .workflows/*/plan/ .workflows/*/specs/ .workflows/*/streams/ -name "*.md" -newer "$CWD/.workflows" -maxdepth 2 2>/dev/null | head -1 || true)

if [ -n "$RECENT_CHECKPOINTS" ]; then
  exit 0
fi

# Warn but don't block (exit 0, not exit 2)
# Use stderr for the warning message
echo "⚠ Workflow files modified without checkpoint. Consider running /workflow-checkpoint before ending session." >&2
exit 0
