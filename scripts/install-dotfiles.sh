#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Bootstrapping your environment..."

DOTFILES="$HOME/.dotfiles"

# Detect OS and call appropriate script
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Detected macOS - using macOS installation script"
    exec "$DOTFILES/scripts/install-dotfiles-mac.sh"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detected Linux - using Ubuntu installation script"
    exec "$DOTFILES/scripts/install-dotfiles-ubuntu.sh"
else
    echo "❌ Unsupported OS type: $OSTYPE"
    echo "Supported systems: macOS (darwin) and Linux (linux-gnu)"
    exit 1
fi