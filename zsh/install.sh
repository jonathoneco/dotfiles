#!/bin/bash

# Install script for zsh configuration

# Set up paths
DOTFILES_DIR="$HOME/.dotfiles"
ZSH_DIR="$DOTFILES_DIR/.oh-my-zsh"

echo "Setting up zsh configuration..."

# Install oh-my-zsh if not present
if [ ! -d "$ZSH_DIR" ]; then
    echo "Installing Oh My Zsh to $ZSH_DIR..."
    export ZSH="$ZSH_DIR"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# Install zsh-syntax-highlighting plugin
if [ ! -d "$ZSH_DIR/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_DIR/custom/plugins/zsh-syntax-highlighting"
fi

echo "✅ Zsh setup complete!"
echo "To activate, restart your terminal or run: source ~/.zshrc"