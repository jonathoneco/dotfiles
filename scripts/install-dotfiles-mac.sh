#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Bootstrapping your environment..."

DOTFILES="$HOME/.dotfiles"

# --- 1. Install dependencies ---
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "📦 Installing packages: zsh, tmux, neovim, fzf, git, build tools..."
brew install zsh tmux neovim fzf git make unzip ripgrep

# --- Install Claude Code ---
if ! command -v claude &>/dev/null; then
  echo "🤖 Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | sh
else
  echo "✅ Claude Code already installed."
fi

# --- Install nvm and latest Node.js ---
if [ ! -d "$HOME/.nvm" ]; then
  echo "📦 Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  
  # Force reload nvm for current session
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
  source "$NVM_DIR/bash_completion" 2>/dev/null || true
  
  echo "🚀 Installing latest Node.js..."
  "$NVM_DIR/nvm.sh" install node
  "$NVM_DIR/nvm.sh" use node
  "$NVM_DIR/nvm.sh" alias default node
else
  echo "✅ nvm already installed."
fi

# --- 2. Install Oh My Zsh ---
if [ ! -d "$DOTFILES/.oh-my-zsh" ]; then
  echo "💡 Installing Oh My Zsh into $DOTFILES/.oh-my-zsh..."
  ZSH="$DOTFILES/.oh-my-zsh" RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

# --- 3. Install powerlevel10k theme ---
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
  echo "🎨 Installing powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "✅ powerlevel10k already installed."
fi

# --- 4. Copy Mac-specific configs ---
echo "📋 Copying Mac-specific configurations..."
cp -r "$DOTFILES/mac/zsh/"* "$DOTFILES/zsh/"
cp -r "$DOTFILES/mac/nvim/"* "$DOTFILES/nvim/"

# --- 5. Set up ZDOTDIR in ~/.zshenv ---
ZDOTDIR_TARGET="$DOTFILES/zsh"
ZSHENV="$HOME/.zshenv"

if ! grep -q 'export ZDOTDIR=' "$ZSHENV" 2>/dev/null; then
  echo "export ZDOTDIR=\"$ZDOTDIR_TARGET\"" >> "$ZSHENV"
  echo "✅ Added ZDOTDIR to $ZSHENV"
else
  sed -i '' "s|export ZDOTDIR=.*|export ZDOTDIR=\"$ZDOTDIR_TARGET\"|" "$ZSHENV"
  echo "🔁 Updated ZDOTDIR in $ZSHENV"
fi

# --- 6. Create Neovim config symlink ---
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

# --- 7. Set up fzf keybindings and completion ---
echo "⚡ Setting up fzf shell integration..."
"$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish

# --- 8. Link tmux config ---
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

