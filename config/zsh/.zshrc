################################################################################
# ZSH configuration
################################################################################
DISABLE_AUTO_TITLE="true" # Disable auto-setting terminal title.
COMPLETION_WAITING_DOTS="true" # Display red dots whilst waiting for completion.
DISABLE_UNTRACKED_FILES_DIRTY="true" # Disable marking untracked files
INC_APPEND_HISTORY="true"
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # Persist history
HISTSIZE=1000000
SAVEHIST=1000000
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

setopt appendhistory
setopt HIST_SAVE_NO_DUPS

# Disable highlight of pastes text
zle_highlight=('paste:none')

# Enabled features
setopt autocd extendedglob nomatch menucomplete interactive_comments

# Disable ctrl-s to freeze terminal.
stty stop undef

# Colors
autoload -Uz colors && colors

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Source zinit
source /usr/share/zinit/zinit.zsh

# Completion plugin – must come before compinit
zinit ice blockf atinit"zpcompinit"
zinit light zsh-users/zsh-completions

# Completions (must be before compinit)
zstyle :compinstall filename '~/.zshrc'
autoload -Uz compinit
compinit

################################################################################
# Command Completions
################################################################################
autoload -Uz compinit

zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zmodload zsh/complist

# Include hidden files
_comp_options+=(globdots)

compinit
################################################################################
# Plugins and packages
################################################################################
source "$ZDOTDIR/user/packages.sh"

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-syntax-highlighting
zinit light hlissner/zsh-autopair

zsh_add_config "config/exports.sh"
zsh_add_config "config/aliases.sh"
zsh_add_config "config/vim-mode.sh"
zsh_add_config "config/helpers.sh"
zsh_add_config "config/fzf.sh"
################################################################################
# Imports
################################################################################
# zsh_add_file "secrets.sh"
################################################################################
# Key bindings
################################################################################
# History substring search keybings - normal mode
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Vim mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
################################################################################
# Misc
################################################################################
eval "$(fnm env --use-on-cd --shell zsh)"
################################################################################
# Extras
################################################################################
# zoxide
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"
