#!/bin/sh
# Open a GUI display layout editor for visual monitor arrangement.
#
# way-displays manages layout automatically via cfg.yaml. This script
# is for visual tweaks — stop the daemon, let the user arrange monitors,
# then restart so cfg.yaml is re-applied (transforms, scale, lid state).

set -eu

lockfile="/tmp/display_editor.lock"

# Prevent concurrent invocations (rapid keybind presses).
exec 9>"$lockfile"
if ! flock -n 9; then
    exit 0
fi

# Stop way-displays to prevent it fighting with the visual editor.
systemctl --user stop way-displays.service

editor=""
if command -v nwg-displays >/dev/null 2>&1; then
    editor=nwg-displays
elif command -v wdisplays >/dev/null 2>&1; then
    editor=wdisplays
fi

if [ -z "$editor" ]; then
    notify-send "Display layout tools not found" \
        "Install nwg-displays or wdisplays for visual monitor arrangement."
    systemctl --user start way-displays.service
    exit 1
fi

notify-send "Display Editor" \
    "Arrange monitors and close when done. Transforms and lid state are managed by way-displays."

# Run the editor and wait for it to exit.
"$editor" || true

# Restart way-displays — it re-applies cfg.yaml (transforms, scale, lid).
if ! systemctl --user start way-displays.service; then
    notify-send -u critical "way-displays failed to restart" \
        "Outputs are unmanaged. Check: journalctl --user -u way-displays"
fi
