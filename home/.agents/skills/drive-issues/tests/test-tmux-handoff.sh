#!/usr/bin/env bash
# Tests the §4 tmux spawn-and-kill boundary used by /drive-issues.
#
# Runs against a NESTED tmux server (its own socket under /tmp) so this
# test cannot affect the user's tmux session. Verifies:
#   1. `tmux new-window -d` creates a window without changing focus.
#   2. `tmux kill-window -t <id>` removes a specific window by id.
#   3. The spawned process outlives the parent window.
#   4. Window count drops to 1 after the kill (only the new window survives).
#
# Run it directly:
#   bash .claude/skills/drive-issues/tests/test-tmux-handoff.sh

set -euo pipefail

SOCK="/tmp/drive-issues-test-$$.sock"
MARKER="/tmp/drive-issues-test-marker-$$"
SESSION="test"

cleanup() {
  tmux -S "$SOCK" kill-server 2>/dev/null || true
  rm -f "$MARKER"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

# --- Setup: nested tmux server with one window ---
tmux -S "$SOCK" new-session -d -s "$SESSION"
ORIG_WIN=$(tmux -S "$SOCK" display-message -t "$SESSION:0" -p '#{window_id}')
[ -n "$ORIG_WIN" ] || fail "could not capture original window id"

# --- Step 1: spawn new window in background, capture id ---
tmux -S "$SOCK" new-window -t "$SESSION" -d "sleep 3 && touch '$MARKER' && sleep 5"

# Verify focus did NOT change to the new window
FOCUSED_AFTER_SPAWN=$(tmux -S "$SOCK" display-message -t "$SESSION" -p '#{window_id}')
[ "$FOCUSED_AFTER_SPAWN" = "$ORIG_WIN" ] \
  || fail "new-window -d changed focus (expected $ORIG_WIN, got $FOCUSED_AFTER_SPAWN)"

# Verify there are now 2 windows
COUNT=$(tmux -S "$SOCK" list-windows -t "$SESSION" | wc -l)
[ "$COUNT" -eq 2 ] || fail "expected 2 windows after spawn, got $COUNT"

# --- Step 2: kill the original window by id ---
tmux -S "$SOCK" kill-window -t "$ORIG_WIN"

# Wait briefly for tmux to settle
sleep 0.5

# Verify only 1 window remains
COUNT=$(tmux -S "$SOCK" list-windows -t "$SESSION" 2>/dev/null | wc -l)
[ "$COUNT" -eq 1 ] || fail "expected 1 window after kill, got $COUNT"

# Verify the surviving window is NOT the original (i.e., the kill targeted correctly)
SURVIVOR=$(tmux -S "$SOCK" display-message -t "$SESSION" -p '#{window_id}')
[ "$SURVIVOR" != "$ORIG_WIN" ] || fail "kill-window did not remove the original"

# --- Step 3: verify spawned process outlives the parent ---
# The spawned command does `sleep 3 && touch MARKER`. We've already used ~0.5s.
# Wait long enough for the marker to appear.
for _ in $(seq 1 20); do
  [ -f "$MARKER" ] && break
  sleep 0.5
done
[ -f "$MARKER" ] || fail "spawned process did not run after parent was killed"

echo "PASS: tmux spawn-and-kill boundary works as /drive-issues §4 expects"
