#!/bin/bash
# Outputs the body of one specific GitHub issue plus the last 5 commits.
# Consumed by /afk-issue: the caller pre-picked the issue, this script just
# loads context for it inside the spawned sub-agent.

set -eo pipefail

[ -z "$1" ] && { echo "ERROR: requires <issue#> as first argument" >&2; exit 1; }
issue="$1"

body=$(gh issue view "$issue" --json number,title,body,labels \
  --jq '"## #\(.number) — \(.title) [\(.labels | map(.name) | join(", "))]\n\n\(.body)\n"' 2>/dev/null) || {
  echo "ERROR: issue #${issue} not found or unreachable" >&2; exit 1;
}
[ -z "$body" ] && { echo "ERROR: issue #${issue} returned empty body" >&2; exit 1; }

commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")

cat <<EOF
# YOUR ISSUE

${body}

# RECENT COMMITS (last 5)

${commits}
EOF
