# Platform-specific PATH configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Apple Silicon Homebrew first
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    # macOS PATH configuration
    export PATH=$HOME/bin:$PATH
    export PATH="/Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin:$PATH"
    export CPATH=/Library/Developer/CommandLineTools
else
    # Ubuntu PATH configuration
    export PATH=$HOME/bin:$PATH
    export PATH="/usr/local/bin:$PATH"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.dotfiles/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
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

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

source $ZDOTDIR/.zsh_profile

# Load zsh-syntax-highlighting if installed
if [ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Platform-specific integrations
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific setup
    # CONDA (manual activation only)
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    # Conda setup without auto-activation - use 'conda activate' manually
    if [[ $- == *i* ]] && [ -f "/Users/jonco/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/jonco/opt/anaconda3/etc/profile.d/conda.sh"
        # Don't auto-activate base environment
        conda config --set auto_activate_base false
    fi
    # <<< conda initialize <<<

    # OPAM
    # opam configuration
    test -r /Users/jonco/.opam/opam-init/init.zsh && . /Users/jonco/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

    # FNM
    eval "$(fnm env --use-on-cd)"
    
    # fzf integration
    source ~/.fzf.zsh
else
    # Ubuntu-specific setup
    # fzf integration for Ubuntu
    source /usr/share/doc/fzf/examples/completion.zsh
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

source $ZDOTDIR/.zshrc_local
