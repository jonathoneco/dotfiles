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
wallpaper_script="$HOME/.azotebg"

# Re-apply wallpaper after layout changes. Runs in background to avoid
# blocking the layout script. Small delay lets sway finish applying outputs.
reapply_wallpaper() {
    if [ -x "$wallpaper_script" ]; then
        ( sleep 1; "$wallpaper_script" ) &
    fi
}

# Check if the laptop lid is closed.
lid_closed=0
lid_state="$(cat /proc/acpi/button/lid/*/state 2>/dev/null | awk '{print $2}')" || true
if [ "$lid_state" = "closed" ]; then
    lid_closed=1
fi

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

# Safety net: never exit with zero active outputs. Re-queries sway state
# and force-enables the internal panel if nothing else is active. Catches
# all edge cases (failed profile restore, timing races, mode mismatches).
# Only runs on abnormal exits — successful paths already ensure outputs.
_layout_ok=0
ensure_active_output() {
    [ "$_layout_ok" -eq 0 ] || return 0
    [ -n "${SWAYSOCK:-}" ] || return 0
    _out="$(run_swaymsg -r -t get_outputs 2>/dev/null)" || return 0
    _ac="$(printf '%s\n' "$_out" | jq '[.[] | select(.active)] | length' 2>/dev/null)" || return 0
    if [ "${_ac:-0}" -eq 0 ]; then
        _edp="$(printf '%s\n' "$_out" | jq -r '.[] | select(.name | startswith("eDP")) | .name' 2>/dev/null | head -n1)" || return 0
        if [ -n "$_edp" ]; then
            run_swaymsg "output $_edp enable scale ${internal_scale:-1.5}" >/dev/null 2>&1 || true
        fi
    fi
}
trap ensure_active_output EXIT

json="$(run_swaymsg -r -t get_outputs 2>/dev/null || true)"
if [ -z "$json" ]; then
    exit 0
fi

# Try to restore a saved profile for the current monitor set.
profile_dir="$state_dir/output-profiles"
if [ -d "$profile_dir" ]; then
    _fp="$(printf '%s\n' "$json" | jq -r '
      [.[] | "\(.make)|\(.model)|\(.serial)"]
      | sort
      | join("\n")
    ')"
    if [ -n "$_fp" ]; then
        _pid="$(printf '%s\n' "$_fp" | md5sum | cut -c1-12)"
        _pfile="$profile_dir/$_pid"
        if [ -f "$_pfile" ]; then
            _restore_ok=1
            _tab="$(printf '\t')"
            while IFS="$_tab" read -r _ident _px _py _sc _tf _mode _active; do
                case "$_ident" in \#*|'') continue ;; esac
                _make="${_ident%%|*}"; _rest="${_ident#*|}"
                _model="${_rest%%|*}"
                _serial="${_rest#*|}"

                _sname="$(printf '%s\n' "$json" | jq -r \
                    --arg m "$_make" --arg mod "$_model" --arg s "$_serial" '
                    .[] | select(.make == $m and .model == $mod and .serial == $s) | .name
                ' | head -n1)"

                if [ -z "$_sname" ]; then
                    _restore_ok=0
                    break
                fi

                # Handle internal display based on current lid state, not
                # the saved active/inactive flag.
                case "$_sname" in
                    eDP*)
                        if [ "$lid_closed" -eq 1 ]; then
                            run_swaymsg "output $_sname disable" >/dev/null 2>&1 || true
                            continue
                        fi
                        ;;
                esac

                # Skip outputs that were saved as inactive and aren't internal
                # (rare edge case — external outputs are usually always active).
                if [ "${_active:-active}" = "inactive" ]; then
                    continue
                fi

                _tf_arg=""
                if [ "$_tf" != "normal" ]; then
                    _tf_arg="transform $_tf"
                fi

                run_swaymsg "output $_sname enable mode $_mode pos $_px $_py scale $_sc $_tf_arg" >/dev/null 2>&1 || true
            done < "$_pfile"

            if [ "$_restore_ok" -eq 1 ]; then
                _layout_ok=1
                reapply_wallpaper
                exit 0
            fi
        fi
    fi
fi

# No saved profile found — fall back to generic algorithm.
# Find internal display regardless of active state — it may have been disabled
# by lid_handler.sh close and we still need to reference it.
internal_name="$(printf '%s\n' "$json" | jq -r '.[] | select(.name | startswith("eDP")) | .name' | head -n1)"

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
    # Safety: always enable internal when no externals are connected, even if lid
    # is closed. A working display behind a closed lid beats zero active outputs
    # (which puts sway into a bad state, e.g. undocking with lid closed).
    if [ -n "$internal_name" ]; then
        run_swaymsg "output $internal_name enable scale $internal_scale pos 0 0" >/dev/null 2>&1 || true
    fi
    _layout_ok=1
    reapply_wallpaper
    exit 0
fi

if [ "$external_count" -eq 1 ]; then
    external_name="$(printf '%s\n' "$external_names" | head -n1)"
    set -- $(get_size "$external_name")
    external_w="$1"
    external_h="$2"

    run_swaymsg "output $external_name enable pos 0 0" >/dev/null 2>&1 || true

    if [ -n "$internal_name" ] && [ "$lid_closed" -eq 0 ]; then
        set -- $(get_size "$internal_name")
        internal_w="$1"
        internal_x=$(( (external_w - internal_w) / 2 ))
        internal_y="$external_h"
        run_swaymsg "output $internal_name enable scale $internal_scale pos $internal_x $internal_y" >/dev/null 2>&1 || true
    fi
    _layout_ok=1
    reapply_wallpaper
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

if [ -n "$internal_name" ] && [ "$lid_closed" -eq 0 ]; then
    set -- $(get_size "$internal_name")
    internal_w="$1"
    internal_x=$(( (span_width - internal_w) / 2 ))
    internal_y="$max_external_h"
    run_swaymsg "output $internal_name enable scale $internal_scale pos $internal_x $internal_y" >/dev/null 2>&1 || true
fi
_layout_ok=1
reapply_wallpaper
