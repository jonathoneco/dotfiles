# Shamelessly stolen from:
# https://github.com/Mach-OS/Machfiles/blob/master/zsh/.config/zsh/zsh-functions

# Function to source config files if they exist
# Usage: zsh_add_config "zsh-prompt"
function zsh_add_config() {
  [ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
}

# Function to source files from anywhere if they exist
# Usage: zsh_add_file "./zsh-prompt"
function zsh_add_file() {
  [ -f "$1" ] && source "$1"
}
