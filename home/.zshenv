export ZDOTDIR=$HOME/.config/zsh

# This file only runs on the bootstrap zsh (no inherited ZDOTDIR). Once
# ZDOTDIR is in env, future zsh invocations read $ZDOTDIR/.zshenv instead
# — chain through so env exports live in one place.
[[ -r "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
