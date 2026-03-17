#!/bin/sh
# Save the current sway output layout as a profile.
# Profiles are keyed by the set of connected monitor identities
# (make/model/serial), so the same layout is restored regardless
# of which DP port a monitor lands on.

set -eu

if [ -z "${SWAYSOCK:-}" ]; then
    echo "SWAYSOCK not set" >&2
    exit 1
fi

profile_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sway/output-profiles"
mkdir -p "$profile_dir"

json="$(swaymsg -r -t get_outputs 2>/dev/null || true)"
if [ -z "$json" ]; then
    echo "Failed to query sway outputs" >&2
    exit 1
fi

# Build fingerprint from sorted monitor identities (all connected outputs).
fingerprint="$(printf '%s\n' "$json" | jq -r '
  [.[] | "\(.make)|\(.model)|\(.serial)"]
  | sort
  | join("\n")
')"

if [ -z "$fingerprint" ]; then
    echo "No outputs found" >&2
    exit 1
fi

profile_id="$(printf '%s\n' "$fingerprint" | md5sum | cut -c1-12)"
profile_file="$profile_dir/$profile_id"

# Generate profile: tab-separated, one line per connected output.
# Inactive outputs (e.g. lid closed) are saved with their current_mode so the
# profile is complete regardless of lid state at save time.
# Format: make|model|serial<TAB>pos_x<TAB>pos_y<TAB>scale<TAB>transform<TAB>WIDTHxHEIGHT<TAB>active
profile_data="$(printf '%s\n' "$json" | jq -r '
  .[]
  | [
      "\(.make)|\(.model)|\(.serial)",
      (if .active then (.rect.x | tostring) else "0" end),
      (if .active then (.rect.y | tostring) else "0" end),
      (.scale | tostring),
      .transform,
      "\(.current_mode.width)x\(.current_mode.height)",
      (if .active then "active" else "inactive" end)
    ]
  | join("\t")
')"

monitor_count="$(printf '%s\n' "$fingerprint" | wc -l)"

{
    printf '# Output layout profile\n'
    printf '# ID: %s\n' "$profile_id"
    printf '# Monitors: %s\n' "$(printf '%s' "$fingerprint" | tr '\n' ', ')"
    printf '# Saved: %s\n' "$(date -Iseconds)"
    printf '%s\n' "$profile_data"
} > "$profile_file"

if [ "${1:-}" != "--quiet" ]; then
    notify-send -t 3000 "Output layout saved" \
        "Profile for $monitor_count monitor(s)" || true
fi
