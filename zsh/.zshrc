export ZSH="$HOME/.dotfiles/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    virtualenv
    zsh-syntax-highlighting
)

# Set up zcompdump path (XDG-compliant and avoids dotfile bloat)
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "$(dirname "$ZSH_COMPDUMP")"

source $ZSH/oh-my-zsh.sh
source $ZDOTDIR/.zsh_profile
source $ZDOTDIR/.zshrc_local
