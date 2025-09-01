#!/bin/bash

set -e
DOTFILES=~/src/dotfiles

# TPM Setup
TPM_LINK="$DOTFILES/config/tmux/plugins/tpm"
[ -L "$TPM_LINK" ] && rm "$TPM_LINK"
[ -d "$TPM_LINK" ] && rm -rf "$TPM_LINK"
ln -s /usr/share/tmux-plugin-manager "$TPM_LINK"

echo "TPM Setup Complete!"

# Install Dotfiles
cd $DOTFILES
stow --target="$HOME/.config" config
stow --target="$HOME/.local/bin" bin
stow --target="$HOME/.local/bin" garden-bin
stow --target="$HOME/.local/secrets" secrets
stow --target="$HOME/.local/share/applications/" applications
sudo stow --target="/etc" etc
stow --target="$HOME" home

echo "Dockfile Stow Complete!"
