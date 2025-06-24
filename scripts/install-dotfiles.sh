#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Bootstrapping your environment..."

DOTFILES="$HOME/.dotfiles"

# Platform detection
# TODO: - Setup install Ubuntu
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="mac"
else
    PLATFORM="ubuntu"
fi

echo "🖥️  Detected platform: $PLATFORM"

# --- Install dependencies ---
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "📦 Installing packages: zsh, tmux, neovim, fzf, git, build tools..."
brew install zsh tmux neovim fzf git make unzip ripgrep deno golang

# --- Install Oh My Zsh ---
if [ ! -d "$DOTFILES/.oh-my-zsh" ]; then
    echo "💡 Installing Oh My Zsh into $DOTFILES/.oh-my-zsh..."
    ZSH="$DOTFILES/.oh-my-zsh" RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh already installed."
fi

# --- Install powerlevel10k theme ---
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    echo "🎨 Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "✅ powerlevel10k already installed."
fi

# --- Install zsh-syntax-highlighting plugin ---
ZSH_CUSTOM_DIR="$DOTFILES/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    mkdir -p "$ZSH_CUSTOM_DIR/plugins"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting already installed."
fi

# --- Set up ZDOTDIR in ~/.zshenv ---
ZDOTDIR_TARGET="$DOTFILES/zsh"
ZSHENV="$HOME/.zshenv"

if ! grep -q 'export ZDOTDIR=' "$ZSHENV" 2>/dev/null; then
    echo "export ZDOTDIR=\"$ZDOTDIR_TARGET\"" >> "$ZSHENV"
    echo "✅ Added ZDOTDIR to $ZSHENV"
else
    sed -i '' "s|export ZDOTDIR=.*|export ZDOTDIR=\"$ZDOTDIR_TARGET\"|" "$ZSHENV"
    echo "🔁 Updated ZDOTDIR in $ZSHENV"
fi

# --- Create Neovim config symlink ---
NVIM_TARGET="$DOTFILES/nvim"
NVIM_LINK="$HOME/.config/nvim"

mkdir -p "$HOME/.config"
if [ -L "$NVIM_LINK" ] || [ -d "$NVIM_LINK" ]; then
    if [ "$(readlink "$NVIM_LINK")" != "$NVIM_TARGET" ]; then
        echo "⚠️  $NVIM_LINK already exists and points elsewhere."
        echo "    Remove or fix manually:"
        echo "    rm -rf \"$NVIM_LINK\" && ln -s \"$NVIM_TARGET\" \"$NVIM_LINK\""
    else
        echo "✅ Neovim symlink already exists: $NVIM_LINK → $NVIM_TARGET"
    fi
else
    ln -s "$NVIM_TARGET" "$NVIM_LINK"
    echo "🔗 Created Neovim symlink: $NVIM_LINK → $NVIM_TARGET"
fi

# --- Set up fzf keybindings and completion ---
echo "⚡ Setting up fzf shell integration..."
"$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish

# --- Link tmux config ---
TMUX_CONF_LINK="$HOME/.tmux.conf"
TMUX_CONF_TARGET="$DOTFILES/tmux/tmux.conf"

if [ -L "$TMUX_CONF_LINK" ] || [ -f "$TMUX_CONF_LINK" ]; then
    if [ "$(readlink "$TMUX_CONF_LINK")" != "$TMUX_CONF_TARGET" ]; then
        echo "⚠️  $TMUX_CONF_LINK already exists and doesn't point to $TMUX_CONF_TARGET."
        echo "    Remove or fix manually:"
        echo "    rm \"$TMUX_CONF_LINK\" && ln -s \"$TMUX_CONF_TARGET\" \"$TMUX_CONF_LINK\""
    else
        echo "✅ Tmux config symlink already exists: $TMUX_CONF_LINK → $TMUX_CONF_TARGET"
    fi
else
    ln -s "$TMUX_CONF_TARGET" "$TMUX_CONF_LINK"
    echo "🔗 Created tmux config symlink: $TMUX_CONF_LINK → $TMUX_CONF_TARGET"
fi

# --- Done ---

echo "🎉 Dotfiles environment setup complete. Restart your terminal to apply Zsh changes."
