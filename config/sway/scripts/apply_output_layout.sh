#!/bin/sh
# shellcheck disable=SC2046  # intentional word splitting on get_size output

set -eu

force_apply=0
if [ "${1:-}" = "--force" ]; then
    force_apply=1
fi

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sway"
mode_file="$state_dir/output-layout-mode"
mode="auto"
if [ -f "$mode_file" ]; then
    mode="$(cat "$mode_file" 2>/dev/null || printf 'auto')"
fi
if [ "$force_apply" -ne 1 ] && [ "$mode" = "manual" ]; then
    exit 0
fi

# Dynamic Sway output layout:
# - 0 external displays: internal at (0,0)
# - 1 external display: external on top, internal centered below
# - 2+ external displays: externals left->right, internal centered below span

internal_scale="${SWAY_INTERNAL_SCALE:-1.5}"

if [ -z "${SWAYSOCK:-}" ]; then
    exit 0
fi

lock_file="${XDG_RUNTIME_DIR:-/tmp}/sway-apply-output-layout.lock"
exec 8>"$lock_file"
if ! flock -w 5 8; then
    exit 0
fi

run_swaymsg() {
    if command -v timeout >/dev/null 2>&1; then
        timeout 2 swaymsg "$@"
        return $?
    fi
    swaymsg "$@"
}

json="$(run_swaymsg -r -t get_outputs 2>/dev/null || true)"
if [ -z "$json" ]; then
    exit 0
fi

internal_name="$(printf '%s\n' "$json" | jq -r '.[] | select(.active and (.name | startswith("eDP"))) | .name' | head -n1)"

get_size() {
    name="$1"
    printf '%s\n' "$json" | jq -r --arg name "$name" '
      .[]
      | select(.name == $name)
      | if .rect.width and .rect.height then
          "\(.rect.width) \(.rect.height)"
        elif .current_mode.width and .current_mode.height then
          "\((.current_mode.width / (.scale // 1)) | floor) \((.current_mode.height / (.scale // 1)) | floor)"
        else
          "0 0"
        end
    '
}

external_names="$(printf '%s\n' "$json" | jq -r --arg internal "$internal_name" '
  .[]
  | select(.active and .name != $internal)
  | .name
')"

external_count="$(printf '%s\n' "$external_names" | sed '/^$/d' | wc -l)"

if [ "$external_count" -eq 0 ]; then
    if [ -n "$internal_name" ]; then
        run_swaymsg "output $internal_name enable scale $internal_scale pos 0 0" >/dev/null 2>&1 || true
    fi
    exit 0
fi

if [ "$external_count" -eq 1 ]; then
    external_name="$(printf '%s\n' "$external_names" | head -n1)"
    set -- $(get_size "$external_name")
    external_w="$1"
    external_h="$2"

    run_swaymsg "output $external_name enable pos 0 0" >/dev/null 2>&1 || true

    if [ -n "$internal_name" ]; then
        set -- $(get_size "$internal_name")
        internal_w="$1"
        internal_x=$(( (external_w - internal_w) / 2 ))
        internal_y="$external_h"
        run_swaymsg "output $internal_name enable scale $internal_scale pos $internal_x $internal_y" >/dev/null 2>&1 || true
    fi
    exit 0
fi

current_x=0
span_width=0
max_external_h=0

for external_name in $external_names; do
    set -- $(get_size "$external_name")
    external_w="$1"
    external_h="$2"

    run_swaymsg "output $external_name enable pos $current_x 0" >/dev/null 2>&1 || true

    current_x=$(( current_x + external_w ))
    span_width=$(( span_width + external_w ))
    if [ "$external_h" -gt "$max_external_h" ]; then
        max_external_h="$external_h"
    fi
done

if [ -n "$internal_name" ]; then
    set -- $(get_size "$internal_name")
    internal_w="$1"
    internal_x=$(( (span_width - internal_w) / 2 ))
    internal_y="$max_external_h"
    run_swaymsg "output $internal_name enable scale $internal_scale pos $internal_x $internal_y" >/dev/null 2>&1 || true
fi
