#!/usr/bin/env bash
# Fast local validation for dotfiles configs
# Runs in <10s without Docker or sudo
#
# Usage: ./validate.sh [--deployed]
#   default:    repo-plane checks (valid on a fresh clone)
#   --deployed: additionally assert the bootstrapped $HOME harness state

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
    for toml_file in \
        config/mise/config.toml \
        config/starship.toml \
        config/aerospace/aerospace.toml \
        config/herdr/config.toml \
        share/herdr/sessionizer.toml; do
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
# Agent harness — repo plane
# --------------------------------------------------------------------------- #

info "Agent harness (repo plane)"

# 0. Required tools actually run. The harness checks below depend on them; a
# missing or broken tool must be a loud FAIL, not a skip that reads as green.
if jq --version >/dev/null 2>&1; then
    pass "jq present and runs"
else
    fail "required tool missing or broken: jq (agent-harness checks depend on it)"
fi
# macOS ships `shasum`, Arch ships `sha256sum`. Resolve one here so the lock
# check below hashes rather than silently comparing empty strings, which reads
# as every vendored skill having diverged.
if echo | sha256sum >/dev/null 2>&1; then
    sha256_of() { sha256sum "$1" | cut -d' ' -f1; }
    pass "sha256 tool present and runs (sha256sum)"
elif echo | shasum -a 256 >/dev/null 2>&1; then
    sha256_of() { shasum -a 256 "$1" | cut -d' ' -f1; }
    pass "sha256 tool present and runs (shasum)"
else
    sha256_of() { printf 'no-sha256-tool\n'; }
    fail "required tool missing or broken: sha256sum/shasum (lock check depends on it)"
fi

# 1. Every in-repo symlink resolves (skill farms, harness AGENTS surfaces).
broken_links=$(find home -type l ! -exec test -e {} \; -print)
if [[ -z "$broken_links" ]]; then
    pass "all in-repo symlinks resolve"
else
    fail "dangling in-repo symlinks:"
    echo "$broken_links" | head -10
fi

# 2. JSON surfaces parse.
if command -v jq >/dev/null 2>&1; then
    for json_file in home/.claude/settings.json home/.pi/agent/settings.json home/.pi/agent/presets.json; do
        if [[ -f "$json_file" ]]; then
            if jq empty "$json_file" 2>/dev/null; then
                pass "json $json_file"
            else
                fail "json $json_file does not parse"
            fi
        fi
    done
else
    skip "jq not installed"
fi

# 3. Every harness surface is a symlink into canonical — one copy, no forks.
for shim in home/.claude/CLAUDE.md home/.codex/AGENTS.md home/.pi/agent/AGENTS.md; do
    if [[ -L "$shim" ]] && [[ -f "$shim" ]]; then
        pass "$shim -> canonical"
    else
        fail "$shim must be a resolving symlink to home/.agents/AGENTS.md"
    fi
done

# 5. Skill manifest matches the store (mattpocock section only).
manifest_skills=$(sed -n 's/^| \([a-z0-9-]*\) | skills\/[a-z-]*\/[a-z0-9-]* |$/\1/p' docs/agent-skills.md | sort)
if [[ -n "$manifest_skills" ]]; then
    # shellcheck disable=SC2012  # skill names are [a-z0-9-] only
    missing_on_disk=$(comm -23 <(echo "$manifest_skills") <(ls home/.agents/skills | sort))
    if [[ -z "$missing_on_disk" ]]; then
        pass "manifest skills all present in store"
    else
        fail "in manifest but missing from store: $(echo "$missing_on_disk" | tr '\n' ' ')"
    fi
else
    fail "could not parse skill rows from docs/agent-skills.md"
fi

# 6. Vendored skill bodies match skills-lock.json (byte pin). A formatter or
# hand-edit silently rewriting a vendored body is exactly the drift this
# catches; refresh-agent-skills.sh --apply is the only writer.
if [[ -f skills-lock.json ]] && jq --version >/dev/null 2>&1; then
    lock_drift=""
    while IFS=$'\t' read -r name expected; do
        [[ -n "$name" ]] || continue
        body="home/.agents/skills/$name/SKILL.md"
        if [[ ! -f "$body" ]]; then
            lock_drift="$lock_drift $name(missing)"
        elif [[ "$(sha256_of "$body")" != "$expected" ]]; then
            lock_drift="$lock_drift $name"
        fi
    done < <(jq -r '.skills | to_entries[] | "\(.key)\t\(.value.computedHash)"' skills-lock.json)
    if [[ -z "$lock_drift" ]]; then
        pass "vendored skill bodies match skills-lock.json"
    else
        fail "vendored bodies diverge from skills-lock.json:$lock_drift"
    fi
else
    fail "skills-lock.json missing or jq unavailable"
fi

# 7. git-guardrail hook behavior table. Every row is a regression receipt —
# the quoted spellings are the bypass class found in review; the allow rows
# keep the hook from creeping into legitimate work.
guardrail=home/.claude/hooks/git-guardrail.sh
guard_case() {
    local expect="$1" cmd="$2" rc=0
    printf '{"tool_input":{"command":"%s"}}' "$cmd" | sh "$guardrail" >/dev/null 2>&1 || rc=$?
    if { [[ "$expect" == block ]] && [[ $rc -ne 0 ]]; } || { [[ "$expect" == allow ]] && [[ $rc -eq 0 ]]; }; then
        pass "guardrail ${expect}s: $cmd"
    else
        fail "guardrail should $expect: $cmd (exit $rc)"
    fi
}
if jq --version >/dev/null 2>&1; then
    guard_case block "git add -A"
    guard_case block "git add '.'"
    guard_case block "git add '-A'"
    guard_case block "git reset --hard HEAD~1"
    guard_case block "git reset '--hard' HEAD~1"
    guard_case block "git clean -fd"
    guard_case block "git checkout ."
    guard_case block "git commit --no-verify -m x"
    guard_case block "git push --force origin main"
    guard_case block "git push -f origin feature/x"
    guard_case block "git push --force-with-lease origin main"
    guard_case block "git push --force-with-lease origin ma'in'"
    guard_case block "git push origin +main"
    guard_case allow "git push --force-with-lease origin feature/x"
    guard_case allow "git add src/app.ts convex/messages.ts"
    guard_case allow "git commit -m 'fix: thing'"
    guard_case allow "git push origin main"
    guard_case allow "git status"
else
    fail "guardrail table needs jq"
fi

# 8. Codex policy stays excluded from stow (seed-if-absent contract).
for excluded in '\.codex/rules/default\\\.rules' '\.codex/config\\\.toml'; do
    if grep -q "$excluded" home/.stow-local-ignore; then
        pass "stow-excluded: $excluded"
    else
        fail "home/.stow-local-ignore must exclude $excluded (seed-if-absent contract)"
    fi
done

# --------------------------------------------------------------------------- #
# Agent harness — deployed plane (opt-in)
# --------------------------------------------------------------------------- #

if [[ "${1:-}" == "--deployed" ]]; then
    info "Agent harness (deployed plane)"

    for deployed in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "$HOME/.pi/agent/AGENTS.md" "$HOME/.agents/AGENTS.md" "$HOME/.claude/skills"; do
        if [[ -e "$deployed" ]]; then
            pass "deployed: $deployed"
        else
            fail "deployed surface missing: $deployed"
        fi
    done

    deployed_broken=$(find "$HOME/.claude/skills/" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null || true)
    if [[ -z "$deployed_broken" ]]; then
        pass "deployed: no dangling skill links"
    else
        fail "deployed: dangling skill links:"
        echo "$deployed_broken" | head -10
    fi

    for machine_file in "$HOME/.codex/rules/default.rules" "$HOME/.codex/config.toml"; do
        if [[ -f "$machine_file" && ! -L "$machine_file" ]]; then
            pass "deployed: $machine_file is a machine-local file (not stow-linked)"
        else
            fail "deployed: $machine_file must exist as a regular file"
        fi
    done
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
