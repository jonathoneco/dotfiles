# Sourced by every zsh invocation (interactive, login, or `zsh -c`) when
# ZDOTDIR is set. Keep this file env-only — no interactive setup.

export EDITOR="${EDITOR:-nvim}"

case "$(uname -s)" in
  Darwin)
    if [[ -z "${BROWSER:-}" ]] || ! command -v "$BROWSER" >/dev/null 2>&1; then
      export BROWSER="open"
    else
      export BROWSER
    fi
    ;;
  *)
    export BROWSER="${BROWSER:-zen-browser}"
    ;;
esac

if [[ -d "/opt/homebrew/bin" ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# Herdr remote attach starts a non-interactive zsh, which does not inherit the
# desktop environment's PATH. Keep user-installed CLIs available there.
export PATH="$HOME/.local/bin:$PATH"

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

# User-installed CLIs (uv, herdr, …). Herdr remote attach starts a
# non-interactive zsh that does not inherit the desktop PATH.
export PATH="$HOME/.local/bin:$PATH"
