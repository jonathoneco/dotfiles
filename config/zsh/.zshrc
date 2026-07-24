#------------------------------------------------------------------------------
# ZSH configuration
#------------------------------------------------------------------------------

zsh_config_dir="${CMUX_REAL_ZDOTDIR:-${ZDOTDIR:-$HOME}}/config"

source "$zsh_config_dir/shell"
source "$zsh_config_dir/aliases"
source "$zsh_config_dir/functions"
source "$zsh_config_dir/prompt"
source "$zsh_config_dir/envs"
source "$zsh_config_dir/init"
[[ -o interactive ]] && source "$zsh_config_dir/bindings"
unset zsh_config_dir

# fastfetch

# bun completions
[ -s "/home/jonco/.bun/_bun" ] && source "/home/jonco/.bun/_bun"
