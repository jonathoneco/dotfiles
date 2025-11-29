#!/bin/bash

set -e
DOTFILES=~/src/dotfiles

# Install Dotfiles
cd $DOTFILES
stow --target="$HOME/.config" config
stow --target="$HOME/.local/bin" bin
stow --target="$HOME/.local/bin" system-bin
stow --target="$HOME/.local/secrets" secrets
stow --target="$HOME/.local/share/applications/" applications
sudo stow --target="/etc" etc
stow --target="$HOME" home

echo "Dockfile Stow Complete!"
