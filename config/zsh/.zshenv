# Sourced by every zsh invocation (interactive, login, or `zsh -c`) when
# ZDOTDIR is set. Keep this file env-only — no interactive setup.

export EDITOR="${EDITOR:-nvim}"
export BROWSER="${BROWSER:-zen-browser}"

# AppImage runtimes export ARGV0; zsh then rewrites argv[0] of every external
# command it runs, which makes mise shim-dispatch re-exec the AppImage
# (runaway process leak). See AppImage/AppImageKit#852.
unset ARGV0
