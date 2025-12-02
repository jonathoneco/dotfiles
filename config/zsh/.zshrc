#------------------------------------------------------------------------------
# ZSH configuration
#------------------------------------------------------------------------------

source $ZDOTDIR/config/shell
source $ZDOTDIR/config/aliases
source $ZDOTDIR/config/functions
source $ZDOTDIR/config/prompt
source $ZDOTDIR/config/envs
source $ZDOTDIR/config/init
[[ -o interactive ]] && source $ZDOTDIR/config/bindings

# fastfetch
