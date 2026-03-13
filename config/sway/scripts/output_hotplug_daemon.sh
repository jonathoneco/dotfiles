#!/bin/sh

set -eu

layout_script="${XDG_CONFIG_HOME:-$HOME/.config}/sway/scripts/apply_output_layout.sh"
lid_handler="${XDG_CONFIG_HOME:-$HOME/.config}/sway/scripts/lid_handler.sh"
daemon_lock="${XDG_RUNTIME_DIR:-/tmp}/sway-output-hotplug.lock"

if [ ! -x "$layout_script" ]; then
    exit 1
fi

if [ -z "${SWAYSOCK:-}" ]; then
    exit 0
fi

# Ensure only one daemon instance runs.
exec 9>"$daemon_lock"
if ! flock -n 9; then
    exit 0
fi

# Apply layout once at startup.
"$layout_script" || true

# Use a FIFO so the read loop runs in the main shell (not a pipe subshell),
# allowing last_run to persist correctly for rate-limiting.
fifo="${XDG_RUNTIME_DIR:-/tmp}/sway-hotplug-events.fifo"
rm -f "$fifo"
mkfifo "$fifo"

cleanup() {
    rm -f "$fifo"
    kill "$swaymsg_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

last_run=0

while :; do
    swaymsg -m -t subscribe '["output"]' > "$fifo" 2>/dev/null &
    swaymsg_pid=$!

    while IFS= read -r _line; do
        now="$(date +%s)"
        if [ $(( now - last_run )) -lt 2 ]; then
            continue
        fi
        # Debounce: wait for rapid-fire events to settle.
        sleep 1
        last_run="$(date +%s)"
        "$layout_script" || true
        # Enforce lid state: if lid is closed, disable internal display.
        # This catches cases where external tools (e.g. wdisplays) re-enable it.
        lid_state="$(cat /proc/acpi/button/lid/*/state 2>/dev/null | awk '{print $2}')" || true
        if [ "$lid_state" = "closed" ] && [ -x "$lid_handler" ]; then
            "$lid_handler" close || true
        fi
    done < "$fifo"

    # swaymsg subscribe exited; restart after brief delay.
    wait "$swaymsg_pid" 2>/dev/null || true
    sleep 1
done
