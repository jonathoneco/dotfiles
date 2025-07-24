#------------------------------------------------------------------------------
# ZSH configuration
#------------------------------------------------------------------------------

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git asdf virtualenv)
source $ZSH/oh-my-zsh.sh

source "$ZDOTDIR/config/profile"

source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

