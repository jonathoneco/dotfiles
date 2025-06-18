#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Bootstrapping your environment..."

DOTFILES="$HOME/.dotfiles"

# --- 1. Install dependencies ---
echo "📦 Installing packages: zsh, tmux, fzf, git, build tools..."
sudo apt update
sudo apt install -y zsh tmux fzf git curl software-properties-common build-essential make unzip ripgrep

# --- Install latest Neovim AppImage ---
if ! command -v nvim &>/dev/null; then
  echo "🚀 Installing latest Neovim AppImage..."
  
  # Download the recommended AppImage
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
  chmod u+x nvim-linux-x86_64.appimage
  
  # Try to run directly first (requires FUSE)
  if ./nvim-linux-x86_64.appimage --version >/dev/null 2>&1; then
    sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
    echo "✅ Neovim AppImage installed to /usr/local/bin/nvim"
  else
    # System doesn't have FUSE, extract the appimage
    echo "FUSE not available, extracting AppImage..."
    ./nvim-linux-x86_64.appimage --appimage-extract
    sudo cp squashfs-root/usr/bin/nvim /usr/local/bin/nvim
    
    # Clean up extraction artifacts
    rm -rf squashfs-root nvim-linux-x86_64.appimage
    echo "✅ Neovim extracted and installed to /usr/local/bin/nvim"
  fi
else
  echo "✅ Neovim already installed."
fi

# --- Install Claude Code ---
# TODO: Skipping for now

# --- Install nvm and latest Node.js ---
if [ ! -d "$HOME/.nvm" ]; then
  echo "📦 Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  
  # Source nvm for current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  
  echo "🚀 Installing latest Node.js..."
  nvm install node
  nvm use node
  nvm alias default node
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

# --- 4. Copy Ubuntu-specific configs ---
echo "📋 Copying Ubuntu-specific configurations..."
cp -r "$DOTFILES/ubuntu/zsh/"* "$DOTFILES/zsh/"
cp -r "$DOTFILES/ubuntu/nvim/"* "$DOTFILES/nvim/"

# --- 5. Set up ZDOTDIR in ~/.zshenv ---
ZDOTDIR_TARGET="$DOTFILES/zsh"
ZSHENV="$HOME/.zshenv"

if ! grep -q 'export ZDOTDIR=' "$ZSHENV" 2>/dev/null; then
  echo "export ZDOTDIR=\"$ZDOTDIR_TARGET\"" >> "$ZSHENV"
  echo "✅ Added ZDOTDIR to $ZSHENV"
else
  sed -i "s|export ZDOTDIR=.*|export ZDOTDIR=\"$ZDOTDIR_TARGET\"|" "$ZSHENV"
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
# Source fzf shell integration files directly
FZF_COMPLETION="/usr/share/doc/fzf/examples/completion.zsh"
FZF_KEYBINDINGS="/usr/share/doc/fzf/examples/key-bindings.zsh"

if [ -f "$FZF_COMPLETION" ] && [ -f "$FZF_KEYBINDINGS" ]; then
  echo "source $FZF_COMPLETION" >> "$HOME/.zshrc"
  echo "source $FZF_KEYBINDINGS" >> "$HOME/.zshrc"
  echo "✅ Added fzf integration to ~/.zshrc"
else
  echo "⚠️  fzf shell integration files not found"
fi

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
