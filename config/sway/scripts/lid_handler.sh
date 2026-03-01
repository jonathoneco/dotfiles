#!/bin/sh

set -eu

action="${1:-}"
case "$action" in
    close|open) ;;
    *)
        echo "Usage: $0 <close|open>" >&2
        exit 1
        ;;
esac

if [ -z "${SWAYSOCK:-}" ]; then
    exit 0
fi

lock_file="${XDG_RUNTIME_DIR:-/tmp}/sway-lid-handler.lock"
exec 7>"$lock_file"
if ! flock -w 5 7; then
    exit 0
fi

run_swaymsg() {
    if command -v timeout >/dev/null 2>&1; then
        timeout 2 swaymsg "$@"
        return $?
    fi
    swaymsg "$@"
}

get_outputs() {
    run_swaymsg -r -t get_outputs 2>/dev/null || true
}

json="$(get_outputs)"
[ -n "$json" ] || exit 0

internal_name="$(printf '%s\n' "$json" | jq -r '.[] | select((.name | startswith("eDP"))) | .name' | head -n1)"
[ -n "$internal_name" ] || exit 0

if [ "$action" = "close" ]; then
    # Safety: only disable laptop display when another display is active.
    external_active_count="$(printf '%s\n' "$json" | jq -r --arg internal "$internal_name" '[.[] | select(.active and .name != $internal)] | length')"
    if [ "${external_active_count:-0}" -ge 1 ]; then
        run_swaymsg "output $internal_name disable" >/dev/null 2>&1 || true
        "${XDG_CONFIG_HOME:-$HOME/.config}/sway/scripts/apply_output_layout.sh" || true
    fi
    exit 0
fi

# Lid opened: re-enable internal panel.
internal_scale="${SWAY_INTERNAL_SCALE:-1.5}"
run_swaymsg "output $internal_name enable scale $internal_scale" >/dev/null 2>&1 || true
"${XDG_CONFIG_HOME:-$HOME/.config}/sway/scripts/apply_output_layout.sh" || true
