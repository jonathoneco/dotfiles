#!/bin/bash

SELECTION="$(printf "󰁹 Auto (AC/BAT)\n󰂃 Power saver\n󰌑 Status" | fuzzel --dmenu -a top-right -l 3 -w 22 -p "TLP profile: ")"

TLP_PROFILE="$(command -v tlp-profile || true)"
if [[ -z "$TLP_PROFILE" && -x "$HOME/.local/bin/tlp-profile" ]]; then
    TLP_PROFILE="$HOME/.local/bin/tlp-profile"
elif [[ -z "$TLP_PROFILE" && -x "$HOME/bin/tlp-profile" ]]; then
    TLP_PROFILE="$HOME/bin/tlp-profile"
fi

notify() {
    if command -v notify-send >/dev/null; then
        notify-send -a tlp-profile -t 4000 "TLP" "$1"
    fi
}

if [[ -z "$TLP_PROFILE" ]]; then
    notify "Failed: tlp-profile not found in PATH, ~/.local/bin, or ~/bin."
    exit 1
fi

case $SELECTION in
    *"󰁹 Auto"*)
        if out="$("$TLP_PROFILE" auto 2>&1)"; then
            notify "Auto mode — AC/BAT profiles follow power source."
        else
            notify "Failed: ${out##*$'\n'}"
        fi
        ;;
    *"󰂃 Power saver"*)
        if out="$("$TLP_PROFILE" saver 2>&1)"; then
            notify "Power saver — aggressive battery profile."
        else
            notify "Failed: ${out##*$'\n'}"
        fi
        ;;
    *"󰌑 Status"*)
        notify "$("$TLP_PROFILE" status | tr '\n' ' · ')"
        ;;
esac
