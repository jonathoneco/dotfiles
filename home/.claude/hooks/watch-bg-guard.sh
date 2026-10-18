#!/bin/sh
# PreToolUse(Bash) guard: a lane watcher (watch-lanes.sh, sandlot-watch*.sh)
# must start through the Bash tool's run_in_background, never with a shell
# `&`, nohup, setsid or disown. A watcher detached by the shell is not tracked
# by the harness: its exit never wakes the session, so lanes go unwatched.
# Exit 2 = block.
set -eu

command=$(jq -r '.tool_input.command // empty')
[ -n "$command" ] || exit 0

case "$command" in
  *watch-lanes.sh*|*sandlot-watch*.sh*) ;;
  *) exit 0 ;;
esac

# Drop the && and redirection spellings of &, so any & left backgrounds a job.
rest=$(printf '%s' "$command" | sed -E -e 's/&&//g' -e 's/[0-9]*>&[0-9-]*//g' -e 's/&>>?//g' -e 's/<&[0-9-]*//g')
case "$rest" in
  *'&'*) bg=true ;;
  *) bg=false ;;
esac
if printf '%s' "$command" | grep -qwE 'nohup|setsid|disown'; then bg=true; fi

if [ "$bg" = true ]; then
  echo "BLOCKED by watch-bg-guard: start the lane watcher with the Bash tool's run_in_background, not &, nohup, setsid or disown." >&2
  exit 2
fi
