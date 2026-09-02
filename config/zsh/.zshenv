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

if [[ -z "${XDG_RUNTIME_DIR:-}" && -d "/run/user/$UID" ]]; then
  export XDG_RUNTIME_DIR="/run/user/$UID"
fi

if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "${XDG_RUNTIME_DIR:-}/bus" ]]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
fi

# Skip on remote sessions (ssh or herdr daemon panes, both stamp SSH_TTY):
# the terminal is on another machine, so clipboard tools should use OSC 52,
# not this machine's wayland socket.
if [[ -z "${SSH_TTY:-}" && -z "${WAYLAND_DISPLAY:-}" && -n "${XDG_RUNTIME_DIR:-}" ]]; then
  # (N) so a box with no compositor gets an empty list instead of zsh's
  # "no matches found" error on every shell startup.
  for socket in "$XDG_RUNTIME_DIR"/wayland-*(N); do
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

# OpenBrain client key for the memory hooks and `python -m agent_memory_client`.
# The file is 0600 and untracked; missing is fine (the hooks then do nothing).
if [[ -r "$HOME/.config/openbrain/client.env" ]]; then
  set -a
  source "$HOME/.config/openbrain/client.env"
  set +a
fi
