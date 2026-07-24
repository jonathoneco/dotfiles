#!/bin/sh
# Refresh vendored mattpocock/skills packages in home/.agents/skills/ from a
# pinned upstream checkout, staged for review. Never mutates the live store
# unless --apply is passed and every gate passes.
#
# Usage:
#   scripts/refresh-agent-skills.sh <upstream-checkout> [--apply]
#
# The checkout's HEAD must match the SHA pinned in docs/agent-skills.md.
# To move the pin: update docs/agent-skills.md (SHA + date) first, then run.
set -eu

repo_root=$(cd "$(dirname "$0")/.." && pwd)
manifest="$repo_root/docs/agent-skills.md"
store="$repo_root/home/.agents/skills"

upstream=${1:?usage: refresh-agent-skills.sh <upstream-checkout> [--apply]}
apply=${2:-}

# shellcheck disable=SC2016  # backticks are literal markdown, not expansion
pinned_sha=$(sed -n 's/.*Pinned SHA: `\([0-9a-f]\{40\}\)`.*/\1/p' "$manifest")
[ -n "$pinned_sha" ] || { echo "ERROR: no pinned SHA in $manifest" >&2; exit 1; }

actual_sha=$(git -C "$upstream" rev-parse HEAD)
if [ "$actual_sha" != "$pinned_sha" ]; then
  echo "ERROR: upstream checkout is at $actual_sha, manifest pins $pinned_sha" >&2
  exit 1
fi

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

# Parse "| skill | skills/... |" rows from the mattpocock table.
rows=$(sed -n 's/^| \([a-z0-9-]*\) | \(skills\/[a-z-]*\/[a-z0-9-]*\) |$/\1 \2/p' "$manifest")
[ -n "$rows" ] || { echo "ERROR: no skill rows parsed from $manifest" >&2; exit 1; }

echo "$rows" | while read -r skill path; do
  src="$upstream/$path"
  [ -d "$src" ] || { echo "ERROR: $skill missing upstream at $path" >&2; exit 1; }
  cp -R "$src" "$stage/$skill"
done

echo "== Diff (live store vs staged upstream) =="
echo "$rows" | while read -r skill _path; do
  if ! diff -r "$store/$skill" "$stage/$skill" >/dev/null 2>&1; then
    echo "-- $skill:"
    diff -r "$store/$skill" "$stage/$skill" 2>&1 | head -40 || true
  fi
done

if [ "$apply" = "--apply" ]; then
  echo "$rows" | while read -r skill _path; do
    rm -rf "${store:?}/$skill"
    cp -R "$stage/$skill" "$store/$skill"
  done
  echo "Applied. Review with: git -C $repo_root status"
else
  echo "Dry run only. Re-run with --apply to write into $store."
fi
