#!/usr/bin/env bash
# Demo of /drive-issues' autonomous loop, sandboxed.
#
# Creates a fresh tmux session running a SIMULATED /drive-issues — same
# tmux mechanics, same per-iteration window cycle, same log file, but no
# real /next-afk teammates and no real /to-pr. The point is to watch the
# windows cycle and the log grow so you trust the mechanism before
# pointing it at production.
#
# Usage:
#   bash .claude/skills/drive-issues/demo.sh        # default 3 fake issues
#   bash .claude/skills/drive-issues/demo.sh 5      # 5 fake issues
#
# Then in another terminal: tmux attach -t drive-issues-demo

set -euo pipefail

N_ISSUES="${1:-3}"
SANDBOX="/tmp/drive-issues-demo-$$"
SESSION="drive-issues-demo"
TICK="${TICK:-2}"  # seconds per phase; bump to slow it down

cleanup() {
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  rm -rf "$SANDBOX"
}
trap cleanup EXIT INT

# --- 1. Sandbox setup -------------------------------------------------------
mkdir -p "$SANDBOX/.issues/done"
for i in $(seq 1 "$N_ISSUES"); do
  printf -v num "%02d" "$i"
  echo "# Issue $num: fake task $i" > "$SANDBOX/.issues/$num-fake-task-$i.md"
done

# --- 2. The per-iteration script that runs INSIDE each tmux window ---------
cat > "$SANDBOX/iterate.sh" <<EOF_OUTER
#!/usr/bin/env bash
set -euo pipefail
cd "\$1"

WIN=\$(tmux display-message -p '#{window_id}')
TS=\$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo
echo "=========================================="
echo "iteration in window \$WIN"
echo "=========================================="

ISSUES=( \$(ls .issues/[0-9]*.md 2>/dev/null) )

# §1: check .issues/
if [ \${#ISSUES[@]} -eq 0 ]; then
  echo "→ §1 .issues/ is empty"
  echo "→ §5 PR phase: simulating /to-pr..."
  sleep $TICK
  cat >> .issues/log.md <<LOG

## \$TS — to-pr
- PR: https://example.com/pulls/42 (demo)
LOG
  echo "→ PR opened (fake). Closing window in 2s..."
  sleep 2
  tmux kill-window -t "\$WIN"
  exit 0
fi

NEXT="\${ISSUES[0]}"
echo "→ §1 found \${#ISSUES[@]} issue(s). Next: \$NEXT"
sleep $TICK

# §2: drive one issue (simulated)
echo "→ §2 driving \$NEXT (simulated /next-afk)..."
sleep $TICK
mv "\$NEXT" ".issues/done/\$(basename "\$NEXT")"
echo "→ moved to .issues/done/"

# §3: triage + log (simulated)
echo "→ §3 triage (simulated)"
sleep $TICK
cat >> .issues/log.md <<LOG

## \$TS — next-afk
- Moved: \$NEXT
- Tests: pass / Typecheck: pass
- Summary: simulated work complete

## \$TS — triage
- (no actions; queue clean)
LOG

# §4: spawn fresh window, kill self
echo "→ §4 spawn fresh window, kill current"
sleep $TICK
NEW_WIN=\$(tmux new-window -P -F '#{window_id}' -d -c "\$1" "bash \$0 \$1")
echo "→ spawned \$NEW_WIN. Killing self (\$WIN) in 1s..."
sleep 1
tmux kill-window -t "\$WIN"
EOF_OUTER
chmod +x "$SANDBOX/iterate.sh"

# --- 3. Start the demo tmux session ----------------------------------------
tmux kill-session -t "$SESSION" 2>/dev/null || true
tmux new-session -d -s "$SESSION" -c "$SANDBOX"
tmux send-keys -t "$SESSION" "bash $SANDBOX/iterate.sh $SANDBOX" Enter

cat <<MSG

╭──────────────────────────────────────────────────────────╮
│ /drive-issues DEMO RUNNING                               │
├──────────────────────────────────────────────────────────┤
│ Session:  $SESSION
│ Sandbox:  $SANDBOX
│ Issues:   $N_ISSUES fake issues
│ Tick:     ${TICK}s per phase (TICK=N to change)
├──────────────────────────────────────────────────────────┤
│ Watch the windows cycle:                                 │
│   tmux attach -t $SESSION                       │
│                                                          │
│ Or tail the log from another terminal:                   │
│   tail -f $SANDBOX/.issues/log.md
│                                                          │
│ Each iteration: §2 drive → §3 triage+log → §4 spawn+kill │
│ Final iteration hits empty .issues/, runs §5 PR phase,   │
│ closes the last window, session ends.                    │
│                                                          │
│ Ctrl-C here to abort and clean up.                       │
╰──────────────────────────────────────────────────────────╯

MSG

# --- 4. Wait for session to end (last window kills itself) -----------------
while tmux has-session -t "$SESSION" 2>/dev/null; do
  sleep 1
done

cat <<MSG

=== Demo complete ===

Final log (.issues/log.md):
MSG
cat "$SANDBOX/.issues/log.md"

cat <<MSG

Final state:
- Issues remaining in .issues/: $(ls "$SANDBOX/.issues/"[0-9]*.md 2>/dev/null | wc -l)
- Issues in .issues/done/:      $(ls "$SANDBOX/.issues/done/"*.md 2>/dev/null | wc -l)

Sandbox cleaned up.
MSG
