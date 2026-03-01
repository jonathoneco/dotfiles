#!/bin/sh

set -eu

"${XDG_CONFIG_HOME:-$HOME/.config}/sway/scripts/set_output_layout_mode.sh" manual || true

if command -v nwg-displays >/dev/null 2>&1; then
    exec nwg-displays
fi

if command -v wdisplays >/dev/null 2>&1; then
    exec wdisplays
fi

notify-send "Display layout tools not found" "Install nwg-displays or wdisplays for visual monitor arrangement."
