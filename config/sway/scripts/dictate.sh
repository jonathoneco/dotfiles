#!/bin/sh
# Voice dictation via Handy + Ollama
# Usage: dictate.sh [--post-process]
#
# Super+V       — raw transcription (Handy → wtype)
# Super+Shift+V — transcription with LLM cleanup (Handy → Ollama → wtype)

HANDY_BIN="$HOME/.local/lib/handy/Handy.AppImage"

# Ensure Handy is installed
if [ ! -x "$HANDY_BIN" ]; then
    notify-send -u critical "Dictation" "Handy not found at $HANDY_BIN"
    exit 1
fi

# Start Handy if not running
# AppImage spawns two processes: the wrapper and an extracted "handy" binary.
# Match --start-hidden to avoid false positives from stale --toggle processes.
if ! pgrep -f "Handy.AppImage --start-hidden" > /dev/null 2>&1 &&
   ! pgrep -f "handy --start-hidden" > /dev/null 2>&1; then
    pkill -f "Handy.AppImage --toggle" 2>/dev/null
    pkill -f "handy --toggle" 2>/dev/null
    "$HANDY_BIN" --start-hidden --no-tray &
    sleep 2
fi

LOG="$HOME/.local/share/com.pais.handy/logs/dictate.log"

if [ "$1" = "--post-process" ]; then
    echo "$(date '+%H:%M:%S') post-process toggle" >> "$LOG"
    # Check Ollama is reachable
    if ! curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
        notify-send -u critical "Dictation" "Ollama not running — run: systemctl start ollama"
        exit 1
    fi
    "$HANDY_BIN" --toggle-post-process
else
    echo "$(date '+%H:%M:%S') raw toggle" >> "$LOG"
    "$HANDY_BIN" --toggle-transcription
fi
