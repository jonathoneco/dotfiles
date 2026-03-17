#!/bin/sh
# Open a GUI display layout editor, then save the resulting layout
# as a profile so it's automatically restored on monitor reconnect.

set -eu

scripts_dir="${XDG_CONFIG_HOME:-$HOME/.config}/sway/scripts"

# Prevent the hotplug daemon from overwriting changes while the editor is open.
"$scripts_dir/set_output_layout_mode.sh" manual || true

editor=""
if command -v nwg-displays >/dev/null 2>&1; then
    editor=nwg-displays
elif command -v wdisplays >/dev/null 2>&1; then
    editor=wdisplays
fi

if [ -z "$editor" ]; then
    notify-send "Display layout tools not found" \
        "Install nwg-displays or wdisplays for visual monitor arrangement."
    exit 1
fi

# Run the editor and wait for it to exit (no exec — we need to save after).
"$editor" || true

# Save the layout the user arranged.
"$scripts_dir/save_output_layout.sh" --quiet || true

# Re-enable automatic layout so the saved profile is applied on hotplug.
"$scripts_dir/set_output_layout_mode.sh" auto || true

notify-send -t 3000 "Display layout saved" \
    "Your arrangement will be restored automatically when these monitors are reconnected." || true
