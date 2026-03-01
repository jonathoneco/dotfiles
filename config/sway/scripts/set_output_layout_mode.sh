#!/bin/sh

set -eu

mode="${1:-}"
case "$mode" in
    auto|manual) ;;
    *)
        echo "Usage: $0 <auto|manual>" >&2
        exit 1
        ;;
esac

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sway"
mode_file="$state_dir/output-layout-mode"

mkdir -p "$state_dir"
printf '%s\n' "$mode" >"$mode_file"
