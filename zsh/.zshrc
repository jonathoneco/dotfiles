export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH=$HOME/bin:$PATH
export PATH="/Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin:$PATH"
export CPATH=/Library/Developer/CommandLineTools

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

if [ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if [[ $- == *i* ]] && [ -f "/Users/jonco/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/Users/jonco/opt/anaconda3/etc/profile.d/conda.sh"
    conda config --set auto_activate_base false
fi

test -r /Users/jonco/.opam/opam-init/init.zsh && . /Users/jonco/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

eval "$(fnm env --use-on-cd)"

source ~/.fzf.zsh

source $ZDOTDIR/.zshrc_local
