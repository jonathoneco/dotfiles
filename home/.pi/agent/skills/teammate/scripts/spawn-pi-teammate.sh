#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 <teammate-name> <prompt-file>" >&2
  exit 2
}

[ $# -eq 2 ] || usage
[ -n "${TMUX:-}" ] || { echo "error: must run inside tmux" >&2; exit 1; }

name="$1"
prompt_file="$2"
[ -f "$prompt_file" ] || { echo "error: prompt file not found: $prompt_file" >&2; exit 1; }

safe_name=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-' | sed 's/^-//; s/-$//')
[ -n "$safe_name" ] || safe_name="teammate"
ts=$(date -u +%Y%m%dT%H%M%SZ)
root=".workflow/teammates"
mkdir -p "$root"
id="${ts}-${safe_name}-$$"
run_prompt="$root/$id.prompt.md"
summary="$root/$id.summary.md"
transcript="$root/$id.transcript.log"
meta="$root/$id.meta"

cat "$prompt_file" > "$run_prompt"
cat >> "$run_prompt" <<EOF

---

# Pi teammate control contract

You are teammate: $name.

Run inside this tmux pane. The lead Pi session is monitoring this pane and the summary file below.

Completion contract:
- When the round is complete or blocked, write a concise closing summary to: $summary
- Include: outcome completed/partial/blocked, issue or part worked, files changed, checks run, commit hash(es), blockers/follow-up.
- After writing the summary, stop working. Do not pick another issue.
- If you need human input, ask in this pane and wait.

Do not start non-Pi harness commands (claude, claude-code) or legacy command paths. Use Pi skill commands (/skill:<name>) only.
EOF

# Start an interactive Pi process in a split pane. The user can focus it and intervene.
pane=$(tmux split-window -h -P -F '#{pane_id}' -c "$PWD" "mise exec -- pi @$run_prompt")
tmux pipe-pane -t "$pane" -o "cat >> '$transcript'"
printf 'id=%q\npane=%q\nprompt=%q\nsummary=%q\ntranscript=%q\n' "$id" "$pane" "$run_prompt" "$summary" "$transcript" > "$meta"

echo "Spawned Pi teammate '$name' in pane $pane"
echo "summary: $summary"
echo "transcript: $transcript"

timeout_seconds="${PI_TEAMMATE_TIMEOUT_SECONDS:-14400}"
deadline=$(( $(date +%s) + timeout_seconds ))

while true; do
  if [ -s "$summary" ]; then
    echo "--- teammate-summary ($name / $pane) ---"
    cat "$summary"
    if [ "${PI_TEAMMATE_KEEP_PANE:-0}" != "1" ]; then
      tmux kill-pane -t "$pane" 2>/dev/null || true
    fi
    exit 0
  fi

  if ! tmux list-panes -a -F '#{pane_id}' | grep -Fxq "$pane"; then
    echo "error: teammate pane $pane exited before writing summary: $summary" >&2
    if [ -s "$transcript" ]; then
      echo "--- teammate-transcript-tail ---" >&2
      tail -200 "$transcript" >&2
    fi
    exit 1
  fi

  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "error: teammate timed out after ${timeout_seconds}s: $pane" >&2
    echo "summary path: $summary" >&2
    echo "transcript path: $transcript" >&2
    exit 124
  fi

  sleep 5
done
