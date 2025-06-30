#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Bootstrapping your environment..."

DOTFILES="$HOME/.dotfiles"

# Detect platform
case "$OSTYPE" in
  darwin*)  PLATFORM="mac" ;;
  linux*)   PLATFORM="linux" ;;
  *)        echo "❌ Unsupported platform: $OSTYPE"; exit 1 ;;
esac

echo "🖥️  Detected platform: $PLATFORM"

# ========== Platform-specific install functions ==========

install_mac_packages() {
  if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "📦 Installing packages with Homebrew..."
  brew install zsh tmux neovim fzf git make unzip ripgrep deno golang
}

install_linux_packages() {
  echo "📦 Installing packages with APT..."
  sudo apt update
  sudo apt install -y zsh tmux neovim fzf git build-essential unzip ripgrep curl wget golang

  # Install deno manually
  if ! command -v deno &>/dev/null; then
    echo "⬇️  Installing Deno..."
    curl -fsSL https://deno.land/install.sh | sh

    # Ensure Deno is in PATH (add to ~/.zshenv)
    if ! grep -q '.deno/bin' "$HOME/.zshenv"; then
      echo 'export PATH="$HOME/.deno/bin:$PATH"' >> "$HOME/.zshenv"
      echo "✅ Added Deno to PATH in .zshenv"
    fi
  else
    echo "✅ Deno already installed."
  fi
}

install_platform_packages() {
  case "$PLATFORM" in
    mac)   install_mac_packages ;;
    linux) install_linux_packages ;;
  esac
}

# ========== Shared install steps ==========

install_oh_my_zsh() {
  if [ ! -d "$DOTFILES/.oh-my-zsh" ]; then
    echo "💡 Installing Oh My Zsh..."
    ZSH="$DOTFILES/.oh-my-zsh" RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "✅ Oh My Zsh already installed."
  fi
}

install_powerlevel10k() {
  P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  if [ ! -d "$P10K_DIR" ]; then
    echo "🎨 Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  else
    echo "✅ powerlevel10k already installed."
  fi
}

install_zsh_plugins() {
  ZSH_CUSTOM_DIR="$DOTFILES/.oh-my-zsh/custom"
  PLUGIN_DIR="$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

  if [ ! -d "$PLUGIN_DIR" ]; then
    echo "🔌 Installing zsh-syntax-highlighting..."
    mkdir -p "$ZSH_CUSTOM_DIR/plugins"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR"
  else
    echo "✅ zsh-syntax-highlighting already installed."
  fi
}

setup_zshenv() {
  ZDOTDIR_TARGET="$DOTFILES/zsh"
  ZSHENV="$HOME/.zshenv"

  if ! grep -q 'export ZDOTDIR=' "$ZSHENV" 2>/dev/null; then
    echo "export ZDOTDIR=\"$ZDOTDIR_TARGET\"" >> "$ZSHENV"
    echo "✅ Added ZDOTDIR to $ZSHENV"
  else
    sed -i'' "s|export ZDOTDIR=.*|export ZDOTDIR=\"$ZDOTDIR_TARGET\"|" "$ZSHENV"
    echo "🔁 Updated ZDOTDIR in $ZSHENV"
  fi
}

setup_nvim_symlink() {
  NVIM_TARGET="$DOTFILES/nvim"
  NVIM_LINK="$HOME/.config/nvim"

  mkdir -p "$HOME/.config"
  if [ -L "$NVIM_LINK" ] || [ -d "$NVIM_LINK" ]; then
    if [ "$(readlink "$NVIM_LINK")" != "$NVIM_TARGET" ]; then
      echo "⚠️  $NVIM_LINK already exists and points elsewhere."
      echo "    Remove or fix manually:"
      echo "    rm -rf \"$NVIM_LINK\" && ln -s \"$NVIM_TARGET\" \"$NVIM_LINK\""
    else
      echo "✅ Neovim symlink already exists."
    fi
  else
    ln -s "$NVIM_TARGET" "$NVIM_LINK"
    echo "🔗 Created Neovim symlink."
  fi
}

setup_tmux_symlink() {
  TMUX_CONF_TARGET="$DOTFILES/tmux/tmux.conf"
  TMUX_CONF_LINK="$HOME/.tmux.conf"

  if [ -L "$TMUX_CONF_LINK" ] || [ -f "$TMUX_CONF_LINK" ]; then
    if [ "$(readlink "$TMUX_CONF_LINK")" != "$TMUX_CONF_TARGET" ]; then
      echo "⚠️  $TMUX_CONF_LINK already exists and points elsewhere."
      echo "    Remove or fix manually:"
      echo "    rm \"$TMUX_CONF_LINK\" && ln -s \"$TMUX_CONF_TARGET\" \"$TMUX_CONF_LINK\""
    else
      echo "✅ Tmux config symlink already exists."
    fi
  else
    ln -s "$TMUX_CONF_TARGET" "$TMUX_CONF_LINK"
    echo "🔗 Created tmux config symlink."
  fi
}

install_fzf_shell_integration() {
  echo "⚡ Setting up fzf shell integration..."

  case "$PLATFORM" in
    mac)
      FZF_INSTALL_SCRIPT="$(brew --prefix)/opt/fzf/install"
      ;;
    linux)
      if [ -f "/usr/share/doc/fzf/examples/install" ]; then
        FZF_INSTALL_SCRIPT="/usr/share/doc/fzf/examples/install"
      elif [ -f "$HOME/.fzf/install" ]; then
        FZF_INSTALL_SCRIPT="$HOME/.fzf/install"
      else
        echo "⚠️  fzf install script not found on Linux. Skipping shell integration."
        return
      fi
      ;;
    *)
      echo "❌ Unsupported platform: $PLATFORM"
      return
      ;;
  esac

  bash "$FZF_INSTALL_SCRIPT" --all --no-bash --no-fish
}


# ========== Run all steps ==========

install_platform_packages
install_oh_my_zsh
install_powerlevel10k
install_zsh_plugins
setup_zshenv
setup_nvim_symlink
setup_tmux_symlink
install_fzf_shell_integration

echo "🎉 Dotfiles environment setup complete. Restart your terminal to apply Zsh changes."

