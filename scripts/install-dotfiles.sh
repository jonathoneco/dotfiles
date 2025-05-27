#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Bootstrapping your environment..."

DOTFILES="$HOME/.dotfiles"
ZDOTDIR_TARGET="$DOTFILES/zsh"
NVIM_TARGET="$DOTFILES/nvim"
ZSHENV="$HOME/.zshenv"
NVIM_LINK="$HOME/.config/nvim"

# --- 1. Install dependencies ---
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "📦 Installing packages: zsh, tmux, neovim, fzf, git..."
brew install zsh tmux neovim fzf git

# --- 2. Install Oh My Zsh ---
if [ ! -d "$DOTFILES/.oh-my-zsh" ]; then
  echo "💡 Installing Oh My Zsh into $DOTFILES/.oh-my-zsh..."
  ZSH="$DOTFILES/.oh-my-zsh" RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

# --- 3. Install powerlevel10k theme ---
P10K_DIR="$DOTFILES/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "🎨 Installing powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "✅ powerlevel10k already installed."
fi

# --- 4. Set up ZDOTDIR in ~/.zshenv ---
if ! grep -q 'export ZDOTDIR=' "$ZSHENV" 2>/dev/null; then
  echo "export ZDOTDIR=\"$ZDOTDIR_TARGET\"" >> "$ZSHENV"
  echo "✅ Added ZDOTDIR to $ZSHENV"
else
  sed -i '' "s|export ZDOTDIR=.*|export ZDOTDIR=\"$ZDOTDIR_TARGET\"|" "$ZSHENV"
  echo "🔁 Updated ZDOTDIR in $ZSHENV"
fi

# --- 5. Create Neovim config symlink ---
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

# --- 6. Set up fzf keybindings and completion ---
echo "⚡ Setting up fzf shell integration..."
"$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish

echo "🎉 Dotfiles environment setup complete. Restart your terminal to apply Zsh changes."
