#!/usr/bin/env bash
# Portable dotfiles installer.
#
# Usage:
#   git clone https://github.com/jonathoneco/dotfiles ~/src/dotfiles && ~/src/dotfiles/install.sh
#
#   # Or one-liner (downloads fully before executing):
#   bash <(curl -fsSL https://raw.githubusercontent.com/jonathoneco/dotfiles/remote/install.sh)
#
# Profiles:
#   --profile minimal   Stow dotfiles only (no tool installation)
#   --profile dev       CLI dev tools + dotfiles (default for SSH/containers)
#   --profile full      Dev + GUI packages (default when desktop session detected)
#
# Options:
#   --skip-system       Skip system package installation (no sudo needed)
#   --skip-stow         Skip dotfiles stow step
#   --skip-nvim         Skip neovim plugin installation (slow)
#
# Environment:
#   GITHUB_USER         GitHub username for dotfiles repo (default: jonathoneco)
#   DOTFILES_BRANCH     Branch to clone (default: remote)
#   DOTFILES_DIR        Where to clone dotfiles (default: ~/src/dotfiles)

main() {
set -euo pipefail

# --------------------------------------------------------------------------- #
# Config
# --------------------------------------------------------------------------- #

GITHUB_USER="${GITHUB_USER:-jonathoneco}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-remote}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/dotfiles}"

PROFILE=""
SKIP_SYSTEM=0
SKIP_STOW=0
SKIP_NVIM=0

# --------------------------------------------------------------------------- #
# Argument parsing
# --------------------------------------------------------------------------- #

while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)    PROFILE="$2"; shift 2 ;;
        --skip-system) SKIP_SYSTEM=1; shift ;;
        --skip-stow)  SKIP_STOW=1; shift ;;
        --skip-nvim)  SKIP_NVIM=1; shift ;;
        -h|--help)    head -24 "$0" | tail -22; exit 0 ;;
        *)            warn "Unknown option: $1"; shift ;;
    esac
done

# --------------------------------------------------------------------------- #
# Logging
# --------------------------------------------------------------------------- #

info()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
ok()    { printf '    \033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '    \033[33m!\033[0m %s\n' "$*"; }
fail()  { printf '    \033[31m✗\033[0m %s\n' "$*"; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

# --------------------------------------------------------------------------- #
# OS / arch detection
# --------------------------------------------------------------------------- #

detect_os() {
    OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m)"

    case "$OS_TYPE" in
        linux)
            if [[ -f /etc/os-release ]]; then
                # shellcheck source=/dev/null
                . /etc/os-release
                OS_DISTRO="${ID_LIKE:-${ID}}"
            else
                OS_DISTRO="unknown"
            fi
            ;;
        darwin) OS_DISTRO="macos" ;;
        *)      OS_DISTRO="unknown" ;;
    esac

    # Normalize: "arch" for Arch/Manjaro, "debian" for Ubuntu/Debian, etc.
    case "$OS_DISTRO" in
        *arch*)   OS_DISTRO="arch" ;;
        *debian*) OS_DISTRO="debian" ;;
        *fedora*|*rhel*) OS_DISTRO="fedora" ;;
    esac
}

detect_profile() {
    if [[ -n "$PROFILE" ]]; then return; fi

    # Auto-detect based on environment
    if [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]] || [[ "$OS_DISTRO" == "macos" ]]; then
        PROFILE="full"
    elif [[ -n "${SSH_CONNECTION:-}" ]] || [[ -f /.dockerenv ]] || grep -q container=lxc /proc/1/environ 2>/dev/null; then
        PROFILE="dev"
    else
        PROFILE="dev"
    fi
}

detect_os
detect_profile

info "Dotfiles installer"
ok "OS: $OS_TYPE ($OS_DISTRO) | Arch: $ARCH | Profile: $PROFILE"

# --------------------------------------------------------------------------- #
# Sudo helper
# --------------------------------------------------------------------------- #

need_sudo() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Cache sudo credentials upfront if we'll need them
if [[ "$SKIP_SYSTEM" -eq 0 && "$EUID" -ne 0 ]]; then
    info "Requesting sudo access for system packages"
    sudo -v
    # Keep-alive: refresh sudo timestamp in background
    (while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null) &
    SUDO_PID=$!
    trap 'kill $SUDO_PID 2>/dev/null' EXIT
fi

# --------------------------------------------------------------------------- #
# Step 1: System packages
# --------------------------------------------------------------------------- #

install_system_packages() {
    if [[ "$SKIP_SYSTEM" -eq 1 ]]; then
        warn "Skipping system packages (--skip-system)"
        return
    fi

    info "Installing system packages"

    case "$OS_DISTRO" in
        arch)
            need_sudo pacman -Syu --noconfirm --needed \
                git curl wget base-devel unzip jq zstd zsh htop \
                fzf fd bat stow xclip tmux ripgrep luarocks clang gcc \
                starship eza zoxide lazygit neovim \
                python python-pip \
                > /dev/null 2>&1
            ok "pacman packages installed"
            ;;
        debian)
            need_sudo apt-get update -qq
            need_sudo apt-get install -y -qq \
                git curl wget build-essential unzip jq zstd zsh htop \
                fzf fd-find bat stow xclip ncurses-term tmux ripgrep luarocks clang gcc \
                python3 python3-pip python3-venv \
                > /dev/null 2>&1
            ok "apt packages installed"

            # Debian/Ubuntu symlinks (fdfind → fd, batcat → bat)
            if command_exists fdfind && ! command_exists fd; then
                need_sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
                ok "fd symlink"
            fi
            if command_exists batcat && ! command_exists bat; then
                need_sudo ln -sf "$(which batcat)" /usr/local/bin/bat
                ok "bat symlink"
            fi
            ;;
        fedora)
            need_sudo dnf install -y \
                git curl wget unzip jq zstd zsh htop \
                fzf fd-find bat stow xclip tmux ripgrep luarocks clang gcc \
                python3 python3-pip \
                > /dev/null 2>&1
            ok "dnf packages installed"
            ;;
        macos)
            if ! command_exists brew; then
                fail "Homebrew not found. Install from https://brew.sh first."
            fi
            brew install \
                git curl wget unzip jq zstd zsh htop \
                fzf fd bat stow tmux ripgrep luarocks llvm gcc \
                starship eza zoxide lazygit neovim mise \
                python3 \
                2>/dev/null
            ok "brew packages installed"
            ;;
        *)
            warn "Unsupported distro ($OS_DISTRO) — skipping system packages"
            ;;
    esac
}

# --------------------------------------------------------------------------- #
# Step 2: Downloaded CLI tools (for distros that don't package them)
# --------------------------------------------------------------------------- #

install_cli_tools() {
    # Arch and macOS already install these via package manager
    if [[ "$OS_DISTRO" == "arch" || "$OS_DISTRO" == "macos" ]]; then
        # mise is the one exception — Arch doesn't have it in official repos
        if [[ "$OS_DISTRO" == "arch" ]] && ! command_exists mise; then
            info "Installing mise"
            curl -fsSL https://mise.jdx.dev/install.sh | sh 2>/dev/null
            if [[ -f "$HOME/.local/bin/mise" ]]; then
                ok "mise $(mise --version 2>/dev/null || echo 'installed')"
            fi
        fi
        return
    fi

    info "Installing CLI tools"

    # -- starship --
    if ! command_exists starship; then
        curl -sS https://starship.rs/install.sh | sh -s -- --yes > /dev/null 2>&1
    fi
    command_exists starship && ok "starship $(starship --version | head -1)" || warn "starship install failed"

    # -- eza --
    if ! command_exists eza; then
        local eza_ver
        eza_ver=$(curl -sL https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d'"' -f4)
        if [[ -n "$eza_ver" ]]; then
            local eza_arch="x86_64-unknown-linux-gnu"
            [[ "$ARCH" == "aarch64" ]] && eza_arch="aarch64-unknown-linux-gnu"
            curl -fsSL "https://github.com/eza-community/eza/releases/download/${eza_ver}/eza_${eza_arch}.tar.gz" \
                | need_sudo tar -xzf - -C /usr/local/bin 2>/dev/null
            need_sudo chmod +x /usr/local/bin/eza
        fi
    fi
    command_exists eza && ok "eza $(eza --version | head -1)" || warn "eza install failed"

    # -- zoxide --
    if ! command_exists zoxide; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh > /dev/null 2>&1
        # zoxide installs to ~/.local/bin; move to system-wide if sudo available
        if [[ -f "$HOME/.local/bin/zoxide" && "$SKIP_SYSTEM" -eq 0 ]]; then
            need_sudo mv "$HOME/.local/bin/zoxide" /usr/local/bin/zoxide
        fi
    fi
    command_exists zoxide && ok "zoxide $(zoxide --version)" || warn "zoxide install failed"

    # -- lazygit --
    if ! command_exists lazygit; then
        local lg_ver
        lg_ver=$(curl -sL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d'"' -f4 | sed 's/^v//')
        if [[ -n "$lg_ver" ]]; then
            local lg_arch="x86_64"
            [[ "$ARCH" == "aarch64" ]] && lg_arch="arm64"
            curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${lg_ver}/lazygit_${lg_ver}_Linux_${lg_arch}.tar.gz" \
                | need_sudo tar -xzf - -C /usr/local/bin lazygit 2>/dev/null
            need_sudo chmod +x /usr/local/bin/lazygit
        fi
    fi
    command_exists lazygit && ok "lazygit $(lazygit --version | head -1)" || warn "lazygit install failed"

    # -- neovim (AppImage) --
    if ! command_exists nvim || [[ "$(nvim --version | head -1)" < "NVIM v0.10" ]]; then
        local nvim_arch="x86_64"
        [[ "$ARCH" == "aarch64" ]] && nvim_arch="aarch64"
        curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.appimage" \
            -o /tmp/nvim.appimage 2>/dev/null
        need_sudo install -m 755 /tmp/nvim.appimage /usr/local/bin/nvim
        rm -f /tmp/nvim.appimage
    fi
    command_exists nvim && ok "neovim $(nvim --version | head -1)" || warn "neovim install failed"

    # -- mise --
    if ! command_exists mise; then
        curl -fsSL https://mise.jdx.dev/install.sh | sh 2>/dev/null
        if [[ -f "$HOME/.local/bin/mise" && "$SKIP_SYSTEM" -eq 0 ]]; then
            need_sudo cp "$HOME/.local/bin/mise" /usr/local/bin/mise
        fi
    fi
    command_exists mise && ok "mise $(mise --version 2>/dev/null || echo 'installed')" || warn "mise install failed"
}

# --------------------------------------------------------------------------- #
# Step 3: GUI packages (full profile only)
# --------------------------------------------------------------------------- #

install_gui_packages() {
    if [[ "$PROFILE" != "full" ]]; then return; fi

    info "Installing GUI packages"

    case "$OS_DISTRO" in
        arch)
            # Install only what's not already present
            local gui_pkgs=(
                foot alacritty kitty                    # terminals
                sway waybar swaybg swayidle swaylock    # compositor
                wl-clipboard grim slurp                 # wayland utils
                noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd  # fonts
                zathura zathura-pdf-mupdf                # pdf viewer
                ranger                                   # file manager
                fastfetch                                # system info
            )
            need_sudo pacman -S --noconfirm --needed "${gui_pkgs[@]}" > /dev/null 2>&1 || true
            ok "GUI packages installed"
            ;;
        macos)
            brew install --cask \
                alacritty kitty \
                font-jetbrains-mono-nerd-font \
                2>/dev/null || true
            ok "GUI casks installed"
            ;;
        *)
            warn "GUI packages not configured for $OS_DISTRO — skipping"
            ;;
    esac
}

# --------------------------------------------------------------------------- #
# Step 4: Clone / update dotfiles
# --------------------------------------------------------------------------- #

clone_dotfiles() {
    info "Setting up dotfiles"

    mkdir -p "$(dirname "$DOTFILES_DIR")"

    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        git -C "$DOTFILES_DIR" checkout "$DOTFILES_BRANCH" 2>/dev/null || true
        git -C "$DOTFILES_DIR" pull --ff-only 2>/dev/null || true
        ok "dotfiles updated ($DOTFILES_DIR, branch: $DOTFILES_BRANCH)"
    else
        git clone --branch "$DOTFILES_BRANCH" \
            "https://github.com/${GITHUB_USER}/dotfiles.git" "$DOTFILES_DIR"
        ok "dotfiles cloned ($DOTFILES_DIR, branch: $DOTFILES_BRANCH)"
    fi

    # Configure git hooks if they exist
    if [[ -d "$DOTFILES_DIR/.githooks" ]]; then
        git -C "$DOTFILES_DIR" config core.hooksPath .githooks
        ok "git hooks configured"
    fi
}

# --------------------------------------------------------------------------- #
# Step 5: Stow dotfiles
# --------------------------------------------------------------------------- #

stow_dotfiles() {
    if [[ "$SKIP_STOW" -eq 1 ]]; then
        warn "Skipping stow (--skip-stow)"
        return
    fi

    if ! command_exists stow; then
        warn "stow not found — skipping dotfiles linking"
        return
    fi

    info "Stowing dotfiles"

    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

    mkdir -p "$config_home" "$HOME/.local/bin" "$HOME/.local/secrets"

    cd "$DOTFILES_DIR"
    stow --adopt --target="$config_home" config            2>/dev/null || true
    stow --adopt --target="$HOME/.local/bin" bin            2>/dev/null || true
    stow --adopt --target="$HOME/.local/secrets" secrets    2>/dev/null || true
    stow --adopt --target="$HOME" home                      2>/dev/null || true

    # Desktop-only stow packages
    if [[ "$PROFILE" == "full" ]]; then
        if [[ -d "$DOTFILES_DIR/applications" ]]; then
            mkdir -p "$HOME/.local/share/applications"
            stow --adopt --target="$HOME/.local/share/applications" applications 2>/dev/null || true
        fi
    fi

    cd - > /dev/null
    ok "dotfiles stowed (config, bin, secrets, home)"

    # Ensure secrets placeholder exists
    if [[ ! -f "$HOME/.local/secrets/secrets.env" ]]; then
        touch "$HOME/.local/secrets/secrets.env"
    fi
}

# --------------------------------------------------------------------------- #
# Step 6: Mise runtimes
# --------------------------------------------------------------------------- #

install_mise_tools() {
    if [[ "$PROFILE" == "minimal" ]]; then return; fi

    if ! command_exists mise; then
        warn "mise not found — skipping runtime installation"
        return
    fi

    info "Installing mise runtimes"

    # Mise config should now be stowed at ~/.config/mise/config.toml
    local mise_config="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
    if [[ ! -f "$mise_config" ]]; then
        warn "No mise config found at $mise_config — skipping"
        return
    fi

    # Trust the config and install
    mise trust "$mise_config" 2>/dev/null || true
    mise install --yes 2>/dev/null || true
    mise reshim 2>/dev/null || true
    ok "mise runtimes installed"

    # Add shims to current session PATH for subsequent steps
    export PATH="$HOME/.local/share/mise/shims:$PATH"
}

# --------------------------------------------------------------------------- #
# Step 7: npm globals
# --------------------------------------------------------------------------- #

install_npm_globals() {
    if [[ "$PROFILE" == "minimal" ]]; then return; fi

    if ! command_exists npm; then
        warn "npm not found — skipping npm globals"
        return
    fi

    info "Installing npm global packages"

    npm install -g tree-sitter-cli > /dev/null 2>&1 && \
        ok "tree-sitter-cli $(tree-sitter --version 2>/dev/null || echo 'installed')" || \
        warn "tree-sitter-cli install failed"

    npm install -g @anthropic-ai/claude-code > /dev/null 2>&1 && \
        ok "claude-code $(claude --version 2>/dev/null || echo 'installed')" || \
        warn "claude-code install failed"
}

# --------------------------------------------------------------------------- #
# Step 8: Neovim plugins
# --------------------------------------------------------------------------- #

install_nvim_plugins() {
    if [[ "$PROFILE" == "minimal" ]]; then return; fi
    if [[ "$SKIP_NVIM" -eq 1 ]]; then
        warn "Skipping neovim plugins (--skip-nvim)"
        return
    fi

    if ! command_exists nvim; then
        warn "nvim not found — skipping plugin installation"
        return
    fi

    local nvim_config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    if [[ ! -d "$nvim_config" ]]; then
        warn "No nvim config found — skipping plugin installation"
        return
    fi

    info "Installing neovim plugins (this takes ~90s for LSPs)..."

    # Step 1: Lazy plugin sync (fast)
    nvim --headless '+Lazy! sync' +qa 2>&1 | grep -v 'MasonUpdate' || true
    ok "plugins synced"

    # Step 2: Deferred quit — Mason LSP installs + treesitter parsers run async on startup
    nvim --headless -c 'lua vim.defer_fn(function() vim.cmd("qall") end, 90000)' 2>/dev/null || true
    ok "LSPs + tree-sitter parsers installed"
}

# --------------------------------------------------------------------------- #
# Step 9: Tmux plugins (TPM)
# --------------------------------------------------------------------------- #

install_tmux_plugins() {
    if [[ "$PROFILE" == "minimal" ]]; then return; fi

    local tmux_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
    local tpm_dir="$tmux_dir/plugins/tpm"

    if [[ ! -f "$tmux_dir/tmux.conf" ]]; then return; fi

    info "Installing tmux plugins"

    mkdir -p "$tmux_dir/plugins"

    if [[ ! -d "$tpm_dir" ]]; then
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
        ok "tpm installed"
    else
        ok "tpm already present"
    fi

    if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
        "$tpm_dir/bin/install_plugins" 2>/dev/null || true
        ok "tmux plugins installed"
    fi
}

# --------------------------------------------------------------------------- #
# Step 10: Directory structure
# --------------------------------------------------------------------------- #

setup_directories() {
    mkdir -p \
        "$HOME/src" \
        "$HOME/.local/bin" \
        "$HOME/.local/go/bin" \
        "${XDG_CONFIG_HOME:-$HOME/.config}" \
        "${XDG_DATA_HOME:-$HOME/.local/share}" \
        "${XDG_STATE_HOME:-$HOME/.local/state}" \
        "${XDG_CACHE_HOME:-$HOME/.cache}"
    ok "directory structure ready"
}

# --------------------------------------------------------------------------- #
# Step 11: Shell setup
# --------------------------------------------------------------------------- #

setup_shell() {
    if [[ "$PROFILE" == "minimal" ]]; then return; fi

    # Set zsh as default shell if available and not already set
    if command_exists zsh; then
        local zsh_path
        zsh_path="$(which zsh)"
        if [[ "$SHELL" != "$zsh_path" ]]; then
            info "Setting default shell to zsh"
            if chsh -s "$zsh_path" 2>/dev/null; then
                ok "default shell set to zsh (restart your session)"
            else
                warn "chsh failed — set manually: chsh -s $zsh_path"
            fi
        else
            ok "shell already zsh"
        fi
    fi
}

# --------------------------------------------------------------------------- #
# Run
# --------------------------------------------------------------------------- #

setup_directories

if [[ "$PROFILE" != "minimal" ]]; then
    install_system_packages
    install_cli_tools
fi

install_gui_packages
clone_dotfiles
stow_dotfiles

if [[ "$PROFILE" != "minimal" ]]; then
    install_mise_tools
    install_npm_globals
    install_nvim_plugins
    install_tmux_plugins
    setup_shell
fi

# --------------------------------------------------------------------------- #
# Summary
# --------------------------------------------------------------------------- #

info "Setup complete! (profile: $PROFILE)"
echo ""
echo "  Installed tools:"
for cmd in starship fzf fd eza zoxide bat lazygit nvim rg stow tmux mise claude tree-sitter; do
    if command_exists "$cmd"; then
        printf "    %-14s %s\n" "$cmd" "$(which "$cmd")"
    else
        printf "    %-14s %s\n" "$cmd" "(not found)"
    fi
done
echo ""
echo "  Dotfiles: $DOTFILES_DIR (branch: $DOTFILES_BRANCH)"
echo ""

if [[ "$SHELL" != *"zsh"* ]]; then
    echo "  Next: restart your shell or run 'exec zsh' to load your config"
else
    echo "  Next: restart your shell or 'source ~/.config/zsh/.zshrc' to reload"
fi
echo ""

}  # end main()

main "$@"
