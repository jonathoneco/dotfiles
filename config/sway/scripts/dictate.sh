#!/bin/sh
# Voice dictation via Handy + Ollama
# Usage: dictate.sh [--post-process]
#
# Super+V       — transcription with LLM cleanup (Handy → Ollama → wtype)
# Super+Shift+V — raw transcription (Handy → wtype)

HANDY_BIN="$HOME/.local/lib/handy/Handy.AppImage"
LOG="$HOME/.local/share/com.pais.handy/logs/dictate.log"

pick_dictation_source() {
    # Handy uses the system default source when no mic is selected. Bluetooth
    # headset mics often appear as default but provide zero samples after
    # reconnects, so prefer the built-in digital mic unless DICTATION_SOURCE is
    # set explicitly.
    if ! command -v pactl >/dev/null 2>&1; then
        return
    fi

    source="${DICTATION_SOURCE:-}"
    if [ -z "$source" ]; then
        source="$(pactl list short sources |
            awk '$2 ~ /^alsa_input\..*Mic__source$/ { print $2; exit }')"
    fi

    if [ -n "$source" ]; then
        pactl set-default-source "$source" 2>/dev/null || return
        pactl set-source-mute "$source" 0 2>/dev/null || true
        pactl set-source-volume "$source" 80% 2>/dev/null || true
        echo "$(date '+%H:%M:%S') source $source" >> "$LOG"
    fi
}

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

pick_dictation_source

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
