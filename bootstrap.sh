#!/bin/bash

# TPM Setup
set -e

DOTFILES="$HOME/dotfiles"
TPM_LINK="$DOTFILES/config/tmux/plugins/tpm"

# Remove any existing symlink or directory
[ -L "$TPM_LINK" ] && rm "$TPM_LINK"
[ -d "$TPM_LINK" ] && rm -rf "$TPM_LINK"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Setting TPM link for Linux (yay install)"
    ln -s /usr/share/tmux-plugin-manager "$TPM_LINK"

else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "TPM setup complete!"

# Install Dotfiles
cd ~/dotfiles
stow --target="$HOME/.config" config
stow home
