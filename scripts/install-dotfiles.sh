#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Bootstrapping your environment..."

DOTFILES="$HOME/.dotfiles"

# Platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="mac"
else
    PLATFORM="ubuntu"
fi

echo "🖥️  Detected platform: $PLATFORM"

# --- Install dependencies ---
if [[ "$PLATFORM" == "mac" ]]; then
    if ! command -v brew &>/dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    echo "📦 Installing packages: zsh, tmux, neovim, fzf, git, build tools..."
    brew install zsh tmux neovim fzf git make unzip ripgrep
else
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
fi

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

# --- Platform-specific configs consolidated into unified nvim config ---
echo "✅ Using unified nvim configuration with platform detection"

# --- Set up ZDOTDIR in ~/.zshenv ---
ZDOTDIR_TARGET="$DOTFILES/zsh"
ZSHENV="$HOME/.zshenv"

if ! grep -q 'export ZDOTDIR=' "$ZSHENV" 2>/dev/null; then
    echo "export ZDOTDIR=\"$ZDOTDIR_TARGET\"" >> "$ZSHENV"
    echo "✅ Added ZDOTDIR to $ZSHENV"
else
    if [[ "$PLATFORM" == "mac" ]]; then
        sed -i '' "s|export ZDOTDIR=.*|export ZDOTDIR=\"$ZDOTDIR_TARGET\"|" "$ZSHENV"
    else
        sed -i "s|export ZDOTDIR=.*|export ZDOTDIR=\"$ZDOTDIR_TARGET\"|" "$ZSHENV"
    fi
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
if [[ "$PLATFORM" == "mac" ]]; then
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
else
    # Ubuntu fzf setup - install and configure shell integration
    if ! command -v fzf &>/dev/null; then
        echo "⚠️  fzf not found, installing via git..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all --no-bash --no-fish
    else
        # Use system-installed fzf integration files
        FZF_COMPLETION="/usr/share/doc/fzf/examples/completion.zsh"
        FZF_KEYBINDINGS="/usr/share/doc/fzf/examples/key-bindings.zsh"
        
        if [ -f "$FZF_COMPLETION" ] && [ -f "$FZF_KEYBINDINGS" ]; then
            echo "✅ Using system fzf integration files"
        else
            echo "⚠️  System fzf integration files not found, using git installation..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all --no-bash --no-fish
        fi
    fi
fi

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