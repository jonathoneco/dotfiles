# Makefile for setting up dotfiles

# ========== Variables ==========
SHELL := /bin/bash
DOTFILES := $(HOME)/.dotfiles
PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:')

# ========== Main Targets ==========

.PHONY: all
all: install

.PHONY: install
install: packages zsh symlinks fzf
	@echo "🎉 Dotfiles environment setup complete. Restart your terminal to apply Zsh changes."

# ========== Package Installation ==========

.PHONY: packages
packages:
ifeq ($(PLATFORM),darwin)
	@echo "📦 Installing packages with Homebrew..."
	@brew install zsh tmux neovim fzf git make unzip ripgrep deno golang
else ifeq ($(PLATFORM),linux)
	@echo "📦 Installing packages with APT..."
	sudo apt update
	sudo apt install -y zsh tmux neovim fzf git build-essential unzip ripgrep curl wget golang luarocks
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
zsh: oh-my-zsh powerlevel10k zsh-plugins zshenv

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
	@P10K_DIR="$(HOME)/.oh-my-zsh/custom/themes/powerlevel10k"; \
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

.PHONY: zshenv
zshenv:
	@ZDOTDIR_TARGET="$(DOTFILES)/zsh"; \
	ZSHENV="$(HOME)/.zshenv"; \
	if ! grep -q 'export ZDOTDIR=' "$$ZSHENV" 2>/dev/null; then \
		echo "export ZDOTDIR=\"$$ZDOTDIR_TARGET\"" >> "$$ZSHENV"; \
		echo "✅ Added ZDOTDIR to $$ZSHENV"; \
	else \
		sed -i'' "s|export ZDOTDIR=.*|export ZDOTDIR=\"$$ZDOTDIR_TARGET\"|" "$$ZSHENV"; \
		echo "🔁 Updated ZDOTDIR in $$ZSHENV"; \
	fi

# ========== Symlinks ==========

.PHONY: symlinks
symlinks: nvim-symlink tmux-symlink

.PHONY: nvim-symlink
nvim-symlink:
	@NVIM_TARGET="$(DOTFILES)/nvim"; \
	NVIM_LINK="$(HOME)/.config/nvim"; \
	mkdir -p "$(HOME)/.config"; \
	if [ -L "$$NVIM_LINK" ] || [ -d "$$NVIM_LINK" ]; then \
		if [ "$$(readlink \"$$NVIM_LINK\")" != "$$NVIM_TARGET" ]; then \
			echo "⚠️  $$NVIM_LINK already exists and points elsewhere."; \
			echo "    Remove or fix manually:"; \
			echo "    rm -rf \"$$NVIM_LINK\" && ln -s \"$$NVIM_TARGET\" \"$$NVIM_LINK\""; \
		else \
			echo "✅ Neovim symlink already exists."; \
		fi; \
	else \
		ln -s "$$NVIM_TARGET" "$$NVIM_LINK"; \
		echo "🔗 Created Neovim symlink."; \
	fi

.PHONY: tmux-symlink
tmux-symlink:
	@TMUX_CONF_TARGET="$(DOTFILES)/tmux/tmux.conf"; \
	TMUX_CONF_LINK="$(HOME)/.tmux.conf"; \
	if [ -L "$$TMUX_CONF_LINK" ] || [ -f "$$TMUX_CONF_LINK" ]; then \
		if [ "$$(readlink \"$$TMUX_CONF_LINK\")" != "$$TMUX_CONF_TARGET" ]; then \
			echo "⚠️  $$TMUX_CONF_LINK already exists and points elsewhere."; \
			echo "    Remove or fix manually:"; \
			echo "    rm \"$$TMUX_CONF_LINK\" && ln -s \"$$TMUX_CONF_TARGET\" \"$$TMUX_CONF_LINK\""; \
		else \
			echo "✅ Tmux config symlink already exists."; \
		fi; \
	else \
		ln -s "$$TMUX_CONF_TARGET" "$$TMUX_CONF_LINK"; \
		echo "🔗 Created tmux config symlink."; \
	fi

# ========== fzf Integration ==========

.PHONY: fzf
fzf:
ifeq ($(PLATFORM),darwin)
	@FZF_INSTALL_SCRIPT="$$(brew --prefix)/opt/fzf/install"; \
	bash "$$FZF_INSTALL_SCRIPT" --all --no-bash --no-fish
else ifeq ($(PLATFORM),linux)
	@if [ -f "/usr/share/doc/fzf/examples/install" ]; then \
		FZF_INSTALL_SCRIPT="/usr/share/doc/fzf/examples/install"; \
	elif [ -f "$(HOME)/.fzf/install" ]; then \
		FZF_INSTALL_SCRIPT="$(HOME)/.fzf/install"; \
	else \
		echo "⚠️  fzf install script not found on Linux. Skipping shell integration."; \
		exit 0; \
	fi; \
	bash "$$FZF_INSTALL_SCRIPT" --all --no-bash --no-fish
endif

# ========== Clean Up ==========

.PHONY: clean
clean:
	@echo "🧹 Cleaning up symlinks..."
	@rm -f "$(HOME)/.tmux.conf"
	@rm -rf "$(HOME)/.config/nvim"
	@echo "✅ Cleaned up symlinks."
