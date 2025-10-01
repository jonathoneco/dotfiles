#------------------------------------------------------------------------------
# ZSH configuration
#------------------------------------------------------------------------------

source $ZDOTDIR/config/shell
source $ZDOTDIR/config/aliases
source $ZDOTDIR/config/functions
source $ZDOTDIR/config/prompt
source $ZDOTDIR/config/init
source $ZDOTDIR/config/envs
[[ -o interactive ]] && source $ZDOTDIR/config/bindings

fastfetch
