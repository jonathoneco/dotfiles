#!/bin/sh
# Watches for a trigger file and plays a notification sound.
# Runs outside the Claude Code sandbox so audio actually works.
TRIGGER="/tmp/.claude-notify-trigger"

# Clean up on exit
trap 'rm -f "$TRIGGER"; exit 0' INT TERM

# Remove stale trigger
rm -f "$TRIGGER"

while true; do
    if [ -f "$TRIGGER" ]; then
        rm -f "$TRIGGER"
        afplay /System/Library/Sounds/Funk.aiff 2>/dev/null &
    fi
    sleep 0.5
done
