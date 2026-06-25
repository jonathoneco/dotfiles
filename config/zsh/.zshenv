# Sourced by every zsh invocation (interactive, login, or `zsh -c`) when
# ZDOTDIR is set. Keep this file env-only — no interactive setup.

export EDITOR="${EDITOR:-nvim}"
export BROWSER="${BROWSER:-zen-browser}"

if [[ -z "${XDG_RUNTIME_DIR:-}" && -d "/run/user/$UID" ]]; then
  export XDG_RUNTIME_DIR="/run/user/$UID"
fi

if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "${XDG_RUNTIME_DIR:-}/bus" ]]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
fi

if [[ -z "${WAYLAND_DISPLAY:-}" && -n "${XDG_RUNTIME_DIR:-}" ]]; then
  for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
    [[ -S "$socket" ]] || continue
    export WAYLAND_DISPLAY="${socket:t}"
    break
  done
fi

# AppImage runtimes export ARGV0; zsh then rewrites argv[0] of every external
# command it runs, which makes mise shim-dispatch re-exec the AppImage
# (runaway process leak). See AppImage/AppImageKit#852.
unset ARGV0
