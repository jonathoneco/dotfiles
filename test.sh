#!/usr/bin/env bash
# Smoke tests for install.sh
#
# Linux distros: spins up clean Docker containers.
# macOS:         spins up a Tart VM (Apple Virtualization.framework).
#
# Usage:
#   ./test.sh                        # All Linux distros (requires docker)
#   ./test.sh --distro arch          # Single Linux distro
#   ./test.sh --distro macos         # macOS VM via Tart (run on a Mac)
#   ./test.sh --distro ubuntu --keep --verbose
#
# Requirements: docker (Linux), tart + sshpass (macOS)
# First macOS run pulls ~15GB base image and installs Homebrew.

set -euo pipefail

# --------------------------------------------------------------------------- #
# Config
# --------------------------------------------------------------------------- #

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISTRO=""
KEEP=0
VERBOSE=0
CONTAINER_PREFIX="dotfiles-test"

# --------------------------------------------------------------------------- #
# CLI parsing
# --------------------------------------------------------------------------- #

while [[ $# -gt 0 ]]; do
    case "$1" in
        --distro)  DISTRO="$2"; shift 2 ;;
        --keep)    KEEP=1; shift ;;
        --verbose) VERBOSE=1; shift ;;
        -h|--help) head -15 "$0" | tail -13; exit 0 ;;
        *)         echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# --------------------------------------------------------------------------- #
# Colors / output
# --------------------------------------------------------------------------- #

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

pass() { printf "  ${GREEN}PASS${RESET} %s\n" "$*"; }
fail() { printf "  ${RED}FAIL${RESET} %s\n" "$*"; }
info() { printf "${BLUE}==>${RESET} ${BOLD}%s${RESET}\n" "$*"; }
warn() { printf "${YELLOW}  !${RESET} %s\n" "$*"; }

# --------------------------------------------------------------------------- #
# Distro matrix (Linux only — macOS handled separately)
# --------------------------------------------------------------------------- #

ALL_DISTROS=(arch ubuntu debian fedora macos)

declare -A IMAGES BOOTSTRAPS
IMAGES=(
    [arch]="archlinux:latest"
    [ubuntu]="ubuntu:24.04"
    [debian]="debian:bookworm"
    [fedora]="fedora:latest"
)
BOOTSTRAPS=(
    [arch]="pacman -Sy --noconfirm git bash curl"
    [ubuntu]="apt-get update -qq && apt-get install -y -qq git bash curl ca-certificates"
    [debian]="apt-get update -qq && apt-get install -y -qq git bash curl ca-certificates"
    [fedora]="dnf install -y git bash curl"
)

DISTROS_TO_RUN=()
if [[ -n "$DISTRO" ]]; then
    local_valid=0
    for d in "${ALL_DISTROS[@]}"; do
        [[ "$d" == "$DISTRO" ]] && local_valid=1
    done
    if [[ "$local_valid" -eq 0 ]]; then
        echo "Unknown distro: $DISTRO (valid: ${ALL_DISTROS[*]})" >&2
        exit 1
    fi
    DISTROS_TO_RUN=("$DISTRO")
else
    # Default: Linux distros only (macOS must be explicitly requested)
    DISTROS_TO_RUN=(arch ubuntu debian fedora)
fi

# --------------------------------------------------------------------------- #
# Validation script (runs after install in both Docker and macOS)
# --------------------------------------------------------------------------- #

VALIDATE_SCRIPT='#!/usr/bin/env bash
set -uo pipefail

PASS=0
FAIL=0
ERRORS=()

check() {
    local label="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf "  \033[0;32mPASS\033[0m %s\n" "$label"
        ((PASS++))
    else
        printf "  \033[0;31mFAIL\033[0m %s\n" "$label"
        ((FAIL++))
        ERRORS+=("$label")
    fi
}

# Soft check — warns but does not count as failure
soft_check() {
    local label="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf "  \033[0;32mPASS\033[0m %s\n" "$label"
        ((PASS++))
    else
        printf "  \033[0;33mSKIP\033[0m %s (non-fatal)\n" "$label"
    fi
}

# Ensure brew + local tools are on PATH
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:/usr/local/bin:$PATH"

echo ""
echo "--- Commands ---"
for cmd in stow fzf fd bat rg starship eza zoxide lazygit nvim mise zsh tmux; do
    check "command: $cmd" command -v "$cmd"
done

echo ""
echo "--- Stow symlinks ---"
for p in \
    "$HOME/.config/zsh" \
    "$HOME/.config/nvim" \
    "$HOME/.config/tmux" \
    "$HOME/.config/mise" \
    "$HOME/.zshenv" \
    "$HOME/.fzfrc" \
    "$HOME/.config/starship.toml"; do
    check "symlink: $p" test -e "$p"
done

echo ""
echo "--- Neovim ---"
check "nvim config: init.lua" test -f "$HOME/.config/nvim/init.lua"
check "nvim config: lua/plugins/" test -d "$HOME/.config/nvim/lua/plugins"
# Lazy.nvim bootstrap clones into data dir; only check if nvim is executable
if nvim --version >/dev/null 2>&1; then
    lazy_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy"
    check "nvim: lazy.nvim cloned" test -d "$lazy_dir/lazy.nvim"
    # At least a handful of plugins should be present after sync
    plugin_count=$(find "$lazy_dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
    check "nvim: plugins synced (${plugin_count} found)" test "$plugin_count" -ge 5
else
    printf "  \033[0;33mSKIP\033[0m nvim plugins (AppImage needs FUSE — not available in Docker)\n"
fi

echo ""
echo "--- Tmux ---"
check "tmux config: tmux.conf" test -f "$HOME/.config/tmux/tmux.conf"
check "tmux: TPM installed" test -d "$HOME/.config/tmux/plugins/tpm"
check "tmux: TPM install_plugins" test -x "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
# tmux-yank is a plugin declared in the config — should be cloned by TPM
soft_check "tmux: tmux-yank plugin" test -d "$HOME/.config/tmux/plugins/tmux-yank"

echo ""
echo "--- Mise runtimes ---"
if command -v mise >/dev/null 2>&1; then
    check "mise trust" mise trust --show
    for tool in go node python rust; do
        check "mise tool: $tool" mise where "$tool"
    done
    # Verify shims are actually on PATH
    for shim in go node python3 rustc; do
        check "shim on PATH: $shim" command -v "$shim"
    done
else
    printf "  \033[0;31mFAIL\033[0m mise not found — skipping runtime checks\n"
    ((FAIL++))
    ERRORS+=("mise not found")
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo "Failures:"
    for e in "${ERRORS[@]}"; do
        echo "  - $e"
    done
fi
exit "$FAIL"
'

# --------------------------------------------------------------------------- #
# Run one Linux distro via Docker
# --------------------------------------------------------------------------- #

run_docker() {
    local distro="$1"
    local image="${IMAGES[$distro]}"
    local bootstrap="${BOOTSTRAPS[$distro]}"
    local container_name="${CONTAINER_PREFIX}-${distro}"
    local exit_code=0

    # Clean up any leftover container from a previous run
    docker rm -f "$container_name" 2>/dev/null || true

    info "$distro ($image)"

    # Install command: bootstrap deps, copy repo, run installer
    local install_cmd
    install_cmd="set -e"
    install_cmd+=" && ${bootstrap}"
    install_cmd+=" && mkdir -p /root/src"
    install_cmd+=" && cp -a /mnt/dotfiles /root/src/dotfiles"
    install_cmd+=" && cd /root/src/dotfiles"
    install_cmd+=" && DOTFILES_DIR=/root/src/dotfiles bash install.sh --profile dev"

    # Pipe the validate script via stdin; install first, then validate
    local full_cmd="${install_cmd} && bash /dev/stdin"

    local docker_args=(
        run
        --name "$container_name"
        -v "${SCRIPT_DIR}:/mnt/dotfiles:ro"
        -e "DOTFILES_DIR=/root/src/dotfiles"
        -i
    )

    # Stream docker output in real-time through tee (captures full log)
    # and a grep filter (shows progress lines). Temporarily disable
    # errexit+pipefail so grep exiting 1 (no matches yet) doesn't kill us.
    local tmplog
    tmplog=$(mktemp)

    set +eo pipefail
    echo "$VALIDATE_SCRIPT" \
        | docker "${docker_args[@]}" "$image" bash -c "$full_cmd" 2>&1 \
        | tee "$tmplog" \
        | if [[ "$VERBOSE" -eq 1 ]]; then
            cat
        else
            grep --line-buffered -E '(==>|[✓✗!]|PASS|FAIL|SKIP|Results|Failures|---)' || true
        fi
    exit_code=${PIPESTATUS[1]}  # docker's exit code
    set -eo pipefail

    # If docker failed and we filtered output, show the error context
    if [[ "$exit_code" -ne 0 && "$VERBOSE" -eq 0 ]]; then
        warn "Container exited $exit_code — last 20 lines:"
        tail -20 "$tmplog" | sed 's/^/    /'
    fi

    rm -f "$tmplog"

    # Clean up container unless --keep
    if [[ "$KEEP" -eq 0 ]]; then
        docker rm -f "$container_name" 2>/dev/null || true
    fi

    return "$exit_code"
}

# --------------------------------------------------------------------------- #
# Tart VM helpers (macOS testing)
# --------------------------------------------------------------------------- #

TART_BASE_IMAGE="ghcr.io/cirruslabs/macos-sequoia-base:latest"
TART_READY_VM="dotfiles-test-base"
TART_TEST_VM="dotfiles-test-macos"
TART_USER="admin"
TART_PASS="admin"
TART_SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)

# SSH into VM with brew on PATH
tart_ssh() {
    local ip="$1"; shift
    sshpass -p "$TART_PASS" ssh "${TART_SSH_OPTS[@]}" "$TART_USER@$ip" \
        "eval \"\$(/opt/homebrew/bin/brew shellenv)\" 2>/dev/null; $*"
}

# Wait for VM SSH, echo IP on success
tart_wait_ssh() {
    local vm="$1" attempts=0
    while [[ $attempts -lt 60 ]]; do
        local ip
        ip=$(tart ip "$vm" 2>/dev/null) || true
        if [[ -n "$ip" ]] && sshpass -p "$TART_PASS" ssh "${TART_SSH_OPTS[@]}" \
                -o ConnectTimeout=3 "$TART_USER@$ip" true 2>/dev/null; then
            echo "$ip"
            return 0
        fi
        sleep 2
        ((attempts++))
    done
    return 1
}

# Stop a running Tart VM by PID and optionally delete it
tart_cleanup() {
    local pid="${1:-}" vm="${2:-}" keep="${3:-0}"
    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null || true
    fi
    if [[ "$keep" -eq 0 && -n "$vm" ]]; then
        tart delete "$vm" 2>/dev/null || true
    fi
}

# One-time: prepare base VM with Homebrew installed
tart_setup_base() {
    info "First-time setup: preparing macOS base VM with Homebrew"
    warn "This pulls ~15GB and installs brew — only needed once"
    echo ""

    tart clone "$TART_BASE_IMAGE" "$TART_READY_VM"

    tart run "$TART_READY_VM" --no-graphics &
    local pid=$!

    info "Waiting for VM to boot..."
    local ip
    ip=$(tart_wait_ssh "$TART_READY_VM") || {
        fail "Base VM did not become SSH-ready"
        tart_cleanup "$pid" "$TART_READY_VM" 0
        return 1
    }
    ok "VM ready ($ip)"

    info "Installing Homebrew..."
    tart_ssh "$ip" \
        'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    ok "Homebrew installed"

    tart_ssh "$ip" "sudo shutdown -h now" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true

    ok "Base VM ready ($TART_READY_VM)"
}

# --------------------------------------------------------------------------- #
# Run macOS test via Tart VM
# --------------------------------------------------------------------------- #

run_macos() {
    local exit_code=0
    local tart_pid=""
    local vm_ip=""

    if [[ "$(uname -s)" != "Darwin" ]]; then
        fail "macos: must be run on a Mac (this host is $(uname -s))"
        return 1
    fi

    # Check prerequisites
    if ! command -v tart &>/dev/null; then
        fail "macos: tart not found"
        warn "Install: brew install cirruslabs/cli/tart"
        return 1
    fi
    if ! command -v sshpass &>/dev/null; then
        fail "macos: sshpass not found"
        warn "Install: brew install hudochenkov/sshpass/sshpass"
        return 1
    fi

    # Ensure base VM with Homebrew exists
    if ! tart list | grep -q "$TART_READY_VM"; then
        tart_setup_base || return 1
    fi

    # Clone fresh VM from base (instant APFS clone)
    tart delete "$TART_TEST_VM" 2>/dev/null || true
    tart clone "$TART_READY_VM" "$TART_TEST_VM"

    info "macos (tart VM: $TART_TEST_VM)"

    # Boot headless with dotfiles dir shared read-only
    tart run "$TART_TEST_VM" --no-graphics --dir=dotfiles:"$SCRIPT_DIR":ro &
    tart_pid=$!

    # Wait for SSH
    info "Waiting for VM..."
    vm_ip=$(tart_wait_ssh "$TART_TEST_VM") || {
        fail "VM did not become SSH-ready after 120s"
        tart_cleanup "$tart_pid" "$TART_TEST_VM" "$KEEP"
        return 1
    }
    ok "VM ready ($vm_ip)"

    # Wait for shared directory mount, then copy repo into VM's home
    local mount_ok=0
    for _ in $(seq 1 15); do
        if tart_ssh "$vm_ip" "test -d '/Volumes/My Shared Files/dotfiles'" 2>/dev/null; then
            mount_ok=1
            break
        fi
        sleep 2
    done

    if [[ "$mount_ok" -eq 1 ]]; then
        tart_ssh "$vm_ip" "mkdir -p ~/src && cp -R '/Volumes/My Shared Files/dotfiles' ~/src/dotfiles"
    else
        warn "Shared directory not available, falling back to scp"
        tart_ssh "$vm_ip" "mkdir -p ~/src"
        sshpass -p "$TART_PASS" scp "${TART_SSH_OPTS[@]}" -rq \
            "$SCRIPT_DIR" "$TART_USER@$vm_ip:~/src/dotfiles"
    fi

    # Run installer with streaming output
    local tmplog
    tmplog=$(mktemp)

    set +eo pipefail
    tart_ssh "$vm_ip" \
        "cd ~/src/dotfiles && DOTFILES_DIR=~/src/dotfiles bash install.sh --profile dev" 2>&1 \
        | tee "$tmplog" \
        | if [[ "$VERBOSE" -eq 1 ]]; then
            cat
        else
            grep --line-buffered -E '(==>|[✓✗!]|PASS|FAIL|SKIP|Results|Failures|---)' || true
        fi
    exit_code=${PIPESTATUS[0]}
    set -eo pipefail

    if [[ "$exit_code" -ne 0 && "$VERBOSE" -eq 0 ]]; then
        warn "Installer exited $exit_code — last 20 lines:"
        tail -20 "$tmplog" | sed 's/^/    /'
    fi

    # Run validation (only if installer succeeded)
    if [[ "$exit_code" -eq 0 ]]; then
        echo "$VALIDATE_SCRIPT" | tart_ssh "$vm_ip" "bash -s"
        exit_code=$?
    fi

    rm -f "$tmplog"

    # Cleanup
    if [[ "$KEEP" -eq 1 ]]; then
        warn "VM kept running: $TART_TEST_VM (IP: $vm_ip)"
        warn "Connect: sshpass -p $TART_PASS ssh ${TART_SSH_OPTS[*]} $TART_USER@$vm_ip"
        warn "Cleanup: tart stop $TART_TEST_VM && tart delete $TART_TEST_VM"
    else
        tart_ssh "$vm_ip" "sudo shutdown -h now" 2>/dev/null || true
        wait "$tart_pid" 2>/dev/null || true
        tart delete "$TART_TEST_VM" 2>/dev/null || true
    fi

    return "$exit_code"
}

# --------------------------------------------------------------------------- #
# Run one distro (dispatcher)
# --------------------------------------------------------------------------- #

run_distro() {
    local distro="$1"
    local exit_code=0

    if [[ "$distro" == "macos" ]]; then
        run_macos || exit_code=$?
    else
        run_docker "$distro" || exit_code=$?
    fi

    if [[ "$exit_code" -eq 0 ]]; then
        RESULTS+=("${distro}:PASS:all checks passed")
    else
        RESULTS+=("${distro}:FAIL:exited $exit_code")
    fi

    return "$exit_code"
}

# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #

# Check prerequisites
HAS_DOCKER=0
command -v docker &>/dev/null && HAS_DOCKER=1

NEEDS_DOCKER=0
for d in "${DISTROS_TO_RUN[@]}"; do
    [[ "$d" != "macos" ]] && NEEDS_DOCKER=1
done

if [[ "$NEEDS_DOCKER" -eq 1 && "$HAS_DOCKER" -eq 0 ]]; then
    echo "Error: docker is required for Linux distro tests but not found" >&2
    echo "  Use --distro macos to run only the macOS VM test" >&2
    exit 1
fi

RESULTS=()
TOTAL_PASS=0
TOTAL_FAIL=0

warn "nvim on non-Arch Linux distros is an AppImage (no FUSE in Docker) — plugin checks skipped there"
warn "Expect ~5-10 min per distro (mise installs Go, Node, Python, Rust + nvim plugin sync)"
echo ""

for distro in "${DISTROS_TO_RUN[@]}"; do
    if run_distro "$distro"; then
        ((TOTAL_PASS++))
    else
        ((TOTAL_FAIL++))
    fi
    echo ""
done

# --------------------------------------------------------------------------- #
# Summary
# --------------------------------------------------------------------------- #

info "Summary"
printf "\n  %-10s %s\n" "DISTRO" "RESULT"
printf "  %-10s %s\n" "------" "------"
for result in "${RESULTS[@]}"; do
    IFS=':' read -r distro status detail <<< "$result"
    if [[ "$status" == "PASS" ]]; then
        printf "  %-10s ${GREEN}%s${RESET}  %s\n" "$distro" "$status" "$detail"
    else
        printf "  %-10s ${RED}%s${RESET}  %s\n" "$distro" "$status" "$detail"
    fi
done
echo ""

if [[ "$TOTAL_FAIL" -gt 0 ]]; then
    fail "${TOTAL_FAIL}/${#DISTROS_TO_RUN[@]} distro(s) failed"
    exit 1
else
    pass "${TOTAL_PASS}/${#DISTROS_TO_RUN[@]} distro(s) passed"
fi
