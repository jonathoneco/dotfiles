# Setup

## Install dependencies
cat deps | sudo pacman -S (or relevant package manager)
Install Hack Nerd Font (or some other nerd font)

## System Considerations
- go is sometimes golang
- setup node with fnm
- Sometimes need to build most recent versions from source (i.e. debian or ubuntu)
    - deno
    - nvim
    - ripgrep
    - golang

## TMUX
- symlink tmux-package-manager to dotfiles, stow to config
- need to stow tpm install to tmux/plugins/tpm


## Todo

### DOTFILES
- copy primeagen stow setup
- .zshrc
- get themeing all synced up
- read the arch wiki for all these configs

### ZSH
- [x] set as default shell
- [x] setup fnm completions `fnm completions --shell <SHELL>` and add `eval "$(fnm env --use-on-cd --shell zsh)"` to shrc
- [x] `fnm use --lts`
- [ ] configure starship
- [ ] Want to get better completions, i.e. case insensitive lower -> upper
- [ ] Currently popd/pushd setting is broken
- [ ] remove 'took n seconds'

### tmux
- theming

### nvim
- use fzf functionality from terminal
- setup keybinds for fzf functions
- rework cht and sessionizer to use fzf functionality
- send ranger file to nvim
