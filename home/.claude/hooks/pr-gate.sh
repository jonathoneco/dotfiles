#!/bin/bash
set -euo pipefail

# PreToolUse hook on Bash — gates git push when branch has an active PR.
# Auto-fixes formatting and simple lint issues, blocks if problems remain.

INPUT=$(cat)

# Extract the command being run
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
if [ "$TOOL" != "Bash" ]; then
  exit 0
fi

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only gate git push commands
if ! echo "$CMD" | grep -qE '^\s*git\s+push'; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd')
cd "$CWD"

# Check if current branch has an active PR
if ! gh pr view --json state -q '.state' 2>/dev/null | grep -q "OPEN"; then
  exit 0
fi

echo "PR detected on this branch — running pre-push checks..." >&2

# 1. Check formatting
UNFORMATTED=$(gofmt -l . 2>/dev/null || true)
if [ -n "$UNFORMATTED" ]; then
  gofmt -w . 2>/dev/null
  COUNT=$(echo "$UNFORMATTED" | wc -l)
  echo "BLOCKED: Auto-formatted $COUNT file(s). Review and commit before pushing:" >&2
  echo "$UNFORMATTED" | sed 's/^/  /' >&2
  exit 2
fi

# 2. Auto-fix lint issues
golangci-lint run --fix ./... 2>/dev/null || true

# Check if auto-fix changed anything
FIXED=$(git diff --name-only 2>/dev/null || true)
if [ -n "$FIXED" ]; then
  COUNT=$(echo "$FIXED" | wc -l)
  echo "BLOCKED: Auto-fixed lint issues in $COUNT file(s). Review changes and commit:" >&2
  echo "$FIXED" | sed 's/^/  /' >&2
  exit 2
fi

# 3. Final lint check — catch issues that can't be auto-fixed
LINT_OUTPUT=$(golangci-lint run ./... 2>&1) || {
  echo "BLOCKED: Lint errors remain. Run /pr-prep for intelligent fixes:" >&2
  echo "$LINT_OUTPUT" >&2
  exit 2
}

# 4. Build check
BUILD_OUTPUT=$(go build ./cmd/server 2>&1) || {
  echo "BLOCKED: Build failed:" >&2
  echo "$BUILD_OUTPUT" >&2
  exit 2
}

exit 0
