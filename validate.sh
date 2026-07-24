#!/usr/bin/env bash
# Fast local validation for dotfiles configs
# Runs in <10s without Docker or sudo
#
# Usage: ./validate.sh

# shellcheck disable=SC2059  # color vars in printf format strings are intentional
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --------------------------------------------------------------------------- #
# Colors / output (matches test.sh)
# --------------------------------------------------------------------------- #

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

FAILURES=0
PASSES=0
SKIPS=0

pass() { printf "  ${GREEN}PASS${RESET} %s\n" "$*"; PASSES=$((PASSES + 1)); }
fail() { printf "  ${RED}FAIL${RESET} %s\n" "$*"; FAILURES=$((FAILURES + 1)); }
skip() { printf "  ${YELLOW}SKIP${RESET} %s\n" "$*"; SKIPS=$((SKIPS + 1)); }
info() { printf "${BLUE}==>${RESET} ${BOLD}%s${RESET}\n" "$*"; }

# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #

# Print shell script paths in a directory (detected by .sh extension or shebang)
find_shell_scripts() {
    local dir="$1"
    [[ -d "$dir" ]] || return 0
    while IFS= read -r f; do
        case "$f" in *.py) continue ;; esac
        if [[ "$f" == *.sh ]]; then
            printf '%s\n' "$f"
        elif [[ -f "$f" ]]; then
            local line
            IFS= read -r line < "$f" 2>/dev/null || continue
            # Match shell shebangs, skip zsh (shellcheck doesn't support it)
            case "$line" in
                \#!*zsh*) ;;
                \#!*sh*) printf '%s\n' "$f" ;;
            esac
        fi
    done < <(find "$dir" -type f 2>/dev/null)
}

run_with_timeout() {
    local seconds="$1"
    shift

    if command -v timeout >/dev/null 2>&1; then
        timeout "$seconds" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$seconds" "$@"
    else
        "$@"
    fi
}

find_toml_python() {
    local python
    for python in python3 python; do
        if command -v "$python" >/dev/null 2>&1 && "$python" -c "import tomllib" 2>/dev/null; then
            printf '%s\n' "$python"
            return 0
        fi
    done
    return 1
}

# --------------------------------------------------------------------------- #
# Checks
# --------------------------------------------------------------------------- #

info "Shellcheck"
if command -v shellcheck >/dev/null 2>&1; then
    for dir in bin system-bin config/sway/scripts; do
        while IFS= read -r script; do
            [[ -n "$script" ]] || continue
            if output=$(shellcheck -x "$script" 2>&1); then
                pass "shellcheck $script"
            else
                fail "shellcheck $script"
                echo "$output" | head -20 || true
            fi
        done < <(find_shell_scripts "$dir")
    done
else
    skip "shellcheck not installed"
fi

info "Sway config"
if command -v sway >/dev/null 2>&1; then
    if output=$(sway -C 2>&1); then
        pass "sway config"
    else
        fail "sway config"
        echo "$output" | head -10 || true
    fi
else
    skip "sway not installed"
fi

info "ZSH syntax"
if command -v zsh >/dev/null 2>&1; then
    if output=$(zsh -n config/zsh/.zshrc 2>&1); then
        pass "zsh -n config/zsh/.zshrc"
    else
        fail "zsh -n config/zsh/.zshrc"
        echo "$output" | head -10 || true
    fi
else
    skip "zsh not installed"
fi

info "Neovim config"
if command -v nvim >/dev/null 2>&1; then
    if output=$(run_with_timeout 10 nvim --headless +'qa!' 2>&1); then
        pass "nvim headless load"
    else
        fail "nvim headless load"
        echo "$output" | head -10 || true
    fi
else
    skip "nvim not installed"
fi

info "TOML syntax"
if TOML_PYTHON="$(find_toml_python)"; then
    for toml_file in config/mise/config.toml config/starship.toml config/aerospace/aerospace.toml; do
        if [[ -f "$toml_file" ]]; then
            if output=$("$TOML_PYTHON" -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb'))" "$toml_file" 2>&1); then
                pass "toml $toml_file"
            else
                fail "toml $toml_file"
                echo "$output" | head -5 || true
            fi
        else
            skip "toml $toml_file (not found)"
        fi
    done
else
    skip "tomllib-capable python not available"
fi

info "Kanata config"
if command -v kanata >/dev/null 2>&1; then
    if output=$(kanata --check --cfg config/kanata/kanata.kbd 2>&1); then
        pass "kanata config/kanata/kanata.kbd"
    else
        fail "kanata config/kanata/kanata.kbd"
        echo "$output" | head -10 || true
    fi
else
    skip "kanata not installed"
fi

info "Ghostty config"
if [[ -f config/ghostty/config.ghostty ]]; then
    if command -v ghostty >/dev/null 2>&1; then
        GHOSTTY_BIN="ghostty"
    elif [[ -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
        GHOSTTY_BIN="/Applications/Ghostty.app/Contents/MacOS/ghostty"
    else
        GHOSTTY_BIN=""
    fi

    if [[ -n "$GHOSTTY_BIN" ]]; then
        if output=$("$GHOSTTY_BIN" +validate-config --config-file=config/ghostty/config.ghostty 2>&1); then
            pass "ghostty config/ghostty/config.ghostty"
        else
            fail "ghostty config/ghostty/config.ghostty"
            echo "$output" | head -10 || true
        fi
    else
        skip "ghostty not installed"
    fi
else
    skip "config/ghostty/config.ghostty (not found)"
fi

# --------------------------------------------------------------------------- #
# Summary
# --------------------------------------------------------------------------- #

echo
printf "${BOLD}Results:${RESET} "
printf "${GREEN}%d passed${RESET}" "$PASSES"
if [[ $SKIPS -gt 0 ]]; then printf ", ${YELLOW}%d skipped${RESET}" "$SKIPS"; fi
if [[ $FAILURES -gt 0 ]]; then printf ", ${RED}%d failed${RESET}" "$FAILURES"; fi
echo

if [[ $FAILURES -gt 0 ]]; then
    exit 1
fi
