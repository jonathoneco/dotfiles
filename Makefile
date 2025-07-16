# Makefile for setting up dotfiles

# ========== Variables ==========
SHELL := /bin/bash
# Use current directory for DOTFILES path for portability
DOTFILES := $(shell pwd)
PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Platform validation
ifeq ($(PLATFORM),)
$(error Unable to detect platform)
endif

ifneq ($(PLATFORM),darwin)
ifneq ($(PLATFORM),linux)
$(warning Unsupported platform: $(PLATFORM). Only darwin and linux are fully supported.)
endif
endif

# ========== Main Targets ==========

.PHONY: all
all: install

.PHONY: install
# 'stow' handles symlinks, 'zsh' handles plugin installation
install: packages zsh stow fzf
	@echo "🎉 Dotfiles environment setup complete. Restart your terminal to apply Zsh changes."

# ========== Package Installation ==========

.PHONY: packages
packages:
ifeq ($(PLATFORM),darwin)
	@echo "📦 Installing packages with Homebrew..."
	@brew install zsh tmux neovim fzf git make unzip ripgrep deno golang stow
else ifeq ($(PLATFORM),linux)
	@echo "📦 Installing packages with APT..."
	@sudo apt update
	@sudo apt install -y zsh tmux fzf git build-essential unzip curl wget stow
	# Install neovim from official repository for latest version
	@if ! command -v nvim &>/dev/null || [ "$$(nvim --version | head -1 | cut -d' ' -f2 | cut -d'v' -f2)" \< "0.9" ]; then \
		echo "⬇️  Installing Neovim..."; \
		wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz; \
		sudo tar -C /opt -xzf /tmp/nvim.tar.gz; \
		sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim; \
		rm /tmp/nvim.tar.gz; \
	else \
		echo "✅ Neovim already installed."; \
	fi
	# Install ripgrep from GitHub releases for better version
	@if ! command -v rg &>/dev/null; then \
		echo "⬇️  Installing ripgrep..."; \
		RG_VERSION=$$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep tag_name | cut -d'"' -f4); \
		wget -q https://github.com/BurntSushi/ripgrep/releases/download/$$RG_VERSION/ripgrep_$${RG_VERSION}_amd64.deb -O /tmp/ripgrep.deb; \
		sudo dpkg -i /tmp/ripgrep.deb; \
		rm /tmp/ripgrep.deb; \
	else \
		echo "✅ ripgrep already installed."; \
	fi
	# Install golang from official repository
	@if ! command -v go &>/dev/null; then \
		echo "⬇️  Installing Go..."; \
		GO_VERSION=$$(curl -s https://go.dev/VERSION?m=text | head -1); \
		wget -q https://go.dev/dl/$$GO_VERSION.linux-amd64.tar.gz -O /tmp/go.tar.gz; \
		sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tar.gz; \
		rm /tmp/go.tar.gz; \
		if ! grep -q '/usr/local/go/bin' "$(HOME)/.zshenv"; then \
			echo 'export PATH="/usr/local/go/bin:$$PATH"' >> "$(HOME)/.zshenv"; \
		fi; \
	else \
		echo "✅ Go already installed."; \
	fi
	# Install deno manually
	@if ! command -v deno &>/dev/null; then \
		echo "⬇️  Installing Deno..."; \
		curl -fsSL https://deno.land/install.sh | sh; \
		if ! grep -q '.deno/bin' "$(HOME)/.zshenv"; then \
			echo 'export PATH="$(HOME)/.deno/bin:$$PATH"' >> "$(HOME)/.zshenv"; \
			echo "✅ Added Deno to PATH in .zshenv"; \
		fi; \
	else \
		echo "✅ Deno already installed."; \
	fi
endif

# ========== Zsh Setup ==========

.PHONY: zsh
zsh: oh-my-zsh powerlevel10k zsh-plugins

.PHONY: oh-my-zsh
oh-my-zsh:
	@if [ ! -d "$(DOTFILES)/.oh-my-zsh" ]; then \
		echo "💡 Installing Oh My Zsh..."; \
		ZSH="$(DOTFILES)/.oh-my-zsh" RUNZSH=no KEEP_ZSHRC=yes \
			sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	else \
		echo "✅ Oh My Zsh already installed."; \
	fi

.PHONY: powerlevel10k
powerlevel10k:
	@P10K_DIR="$(DOTFILES)/.oh-my-zsh/custom/themes/powerlevel10k"; \
	if [ ! -d "$$P10K_DIR" ]; then \
		echo "🎨 Installing powerlevel10k..."; \
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$$P10K_DIR"; \
	else \
		echo "✅ powerlevel10k already installed."; \
	fi

.PHONY: zsh-plugins
zsh-plugins:
	@ZSH_CUSTOM_DIR="$(DOTFILES)/.oh-my-zsh/custom"; \
	PLUGIN_DIR="$$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"; \
	if [ ! -d "$$PLUGIN_DIR" ]; then \
		echo "🔌 Installing zsh-syntax-highlighting..."; \
		mkdir -p "$$ZSH_CUSTOM_DIR/plugins"; \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$$PLUGIN_DIR"; \
	else \
		echo "✅ zsh-syntax-highlighting already installed."; \
	fi

# ========== Stow Symlinks ==========

.PHONY: stow
stow:
	@echo "🔗 Stowing packages via GNU Stow..."
	@echo "   -> Stowing zsh and tmux to $(HOME)"
	@stow -d $(DOTFILES) -t $(HOME) zsh tmux
	@echo "   -> Stowing nvim to $(HOME)/.config/nvim"
	@mkdir -p "$(HOME)/.config/nvim"
	@stow -d $(DOTFILES) -t "$(HOME)/.config/nvim" nvim
	@echo "✅ Stow complete."

# ========== fzf Integration ==========

.PHONY: fzf
fzf:
ifeq ($(PLATFORM),darwin)
	@FZF_INSTALL_SCRIPT="$(brew --prefix)/opt/fzf/install"; \
	bash "$FZF_INSTALL_SCRIPT" --all --no-bash --no-fish
else ifeq ($(PLATFORM),linux)
	@if [ -f "/usr/share/doc/fzf/examples/install" ]; then \
		FZF_INSTALL_SCRIPT="/usr/share/doc/fzf/examples/install"; \
	elif [ -f "$(HOME)/.fzf/install" ]; then \
		FZF_INSTALL_SCRIPT="$(HOME)/.fzf/install"; \
	else \
		echo "⚠️  fzf install script not found on Linux. Skipping shell integration."; \
		exit 0; \
	fi; \
	bash "$FZF_INSTALL_SCRIPT" --all --no-bash --no-fish
endif

# ========== Clean Up ==========

.PHONY: clean
clean:
	@echo "🧹 Cleaning up stowed packages..."
	@stow -D -d $(DOTFILES) -t $(HOME) zsh tmux
	@stow -D -d $(DOTFILES) -t "$(HOME)/.config/nvim" nvim
	@echo "✅ Cleaned up stowed packages."
