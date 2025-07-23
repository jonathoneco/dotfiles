################################################################################
# Aliases
#
# To remove an alias: `unalias `
################################################################################

# List
alias ls='ls -G --color=auto'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias lsa='ls -lah'

# General
alias grep="grep --color=auto"
alias editdots="cd ~/dotfiles; nvim"

# Vim
alias vimdiff='nvim -d'
alias vim="nvim"
# alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'

# ZSH
alias zsh:reload="source $ZDOTDIR/.zshrc"
alias zsh:edit="nvim $ZDOTDIR/.zshrc"
alias zsh:alias="cat ~/.config/zsh/config/aliases.sh"
alias zsh:alias:edit="nvim ~/.config/zsh/config/aliases.sh"

# Tmux
alias t="tmux"
alias ta="t a -t"
alias tls="t ls"
alias tn="t new -t"
