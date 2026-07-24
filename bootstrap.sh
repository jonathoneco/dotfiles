#!/bin/bash
#
# Idempotent bootstrap for this dotfiles repo.
# Handles stow packages, systemd user unit symlinks, and native agent skill
# directory symlinks that stow can't fit.
#
# Re-runnable: existing symlinks are replaced with `ln -sfn`.

set -e
shopt -s nullglob

DOTFILES="${DOTFILES:-$HOME/src/dotfiles}"
OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
BACKUP_DIR="$HOME/.dotfiles-bootstrap-backup/$(date +%Y%m%d-%H%M%S)"

backup_real_file() {
  local rel="$1"
  local target="$HOME/$rel"
  local physical

  if [[ -f "$target" && ! -L "$target" ]]; then
    physical="$(cd "$(dirname "$target")" && pwd -P)/$(basename "$target")"
    case "$physical" in
      "$DOTFILES"/*) return ;;
    esac

    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
  fi
}

backup_config_file() {
  local rel="$1"
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local target="$config_home/$rel"
  local physical

  if [[ -f "$target" && ! -L "$target" ]]; then
    physical="$(cd "$(dirname "$target")" && pwd -P)/$(basename "$target")"
    case "$physical" in
      "$DOTFILES"/*) return ;;
    esac

    mkdir -p "$BACKUP_DIR/.config/$(dirname "$rel")"
    mv "$target" "$BACKUP_DIR/.config/$rel"
  fi
}

# ────────────────────────────────────────────────────────────────────────────
# 1. Stow packages
# ────────────────────────────────────────────────────────────────────────────
cd "$DOTFILES"
config_ignores=()
if [[ "$OS_TYPE" == "darwin" ]]; then
  config_ignores=(
    --ignore='environment\.d'
    --ignore='uwsm'
    --ignore='sway'
    --ignore='waybar'
    --ignore='foot'
    --ignore='way-displays'
    --ignore='systemd'
  )
fi

backup_config_file mise/config.toml
backup_config_file kitty/kitty.conf
backup_real_file .claude/settings.json
backup_real_file .codex/config.toml
backup_real_file .codex/rules/default.rules
backup_real_file .pi/agent/settings.json
backup_real_file .pi/agent/extensions/superset-hooks.ts
if [[ "$OS_TYPE" == "darwin" ]]; then
  backup_real_file "Library/Application Support/org.yanex.marta/conf.marco"
  backup_real_file "Library/Application Support/org.yanex.marta/favorites.marco"
fi

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/secrets"
stow --target="$HOME/.config" "${config_ignores[@]}" config
stow --target="$HOME/.local/bin" bin
if [[ "$OS_TYPE" != "darwin" ]]; then
  stow --target="$HOME/.local/bin" system-bin
fi
stow --target="$HOME/.local/secrets" secrets
if [[ "$OS_TYPE" == "darwin" ]]; then
  stow --target="$HOME" marta
fi
if [[ "$OS_TYPE" != "darwin" ]]; then
  stow --target="$HOME/.local/share/applications/" applications
  sudo stow --target="/etc" etc
fi

# TLP overrides live in /etc/tlp.d/ (available before /home mounts). Older
# bootstraps stowed etc/tlp.conf over pacman's file with a home-dir symlink,
# which breaks tlp.service at boot. Copy the drop-in — do not symlink into ~.
if [[ "$OS_TYPE" != "darwin" && -L /etc/tlp.conf ]]; then
  case "$(readlink /etc/tlp.conf)" in
    *dotfiles/etc/tlp.conf)
      sudo rm /etc/tlp.conf
      if pacman -Q tlp &>/dev/null; then
        sudo pacman -S --noconfirm tlp
      fi
      ;;
  esac
fi
if [[ "$OS_TYPE" != "darwin" ]]; then
  sudo install -Dm644 "$DOTFILES/share/tlp/99-dotfiles.conf" /etc/tlp.d/99-dotfiles.conf
  sudo systemctl restart tlp 2>/dev/null || true
fi

# Keep NetworkManager, systemd-resolved, and Tailscale on one resolver path.
# Tailscale's DNS manager behaves best when /etc/resolv.conf is the resolved
# stub and NetworkManager feeds per-link DNS into resolved.
if [[ "$OS_TYPE" != "darwin" ]]; then
  sudo install -Dm644 "$DOTFILES/share/networkmanager/10-dns-systemd-resolved.conf" \
    /etc/NetworkManager/conf.d/10-dns-systemd-resolved.conf
  sudo systemctl enable --now systemd-resolved
  sudo ln -sfn /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  sudo systemctl restart NetworkManager 2>/dev/null || true
  sudo systemctl restart tailscaled 2>/dev/null || true
fi

# Use the stock sway session (/usr/share/wayland-sessions/sway.desktop).
# Custom GPU-pinning wrappers broke SDDM login twice (sway-session, then
# sway-sddm-session via the WLR_DRM_DEVICES colon bug — wlroots #1386);
# wlroots auto-probing picks the Intel KMS device as primary on its own.
if [[ "$OS_TYPE" != "darwin" ]]; then
  sudo rm -f /usr/local/bin/sway-session /usr/local/bin/sway-sddm-session
  sudo rm -f /usr/share/wayland-sessions/sway-nvidia.desktop
  # Retire ad-hoc system-sleep hook if present (suspend policy is logind + swayidle).
  sudo rm -f /etc/systemd/system-sleep/99-garden-suspend.sh
fi

mkdir -p "$HOME/.claude" "$HOME/.cursor" "$HOME/.codex/rules" "$HOME/.pi/agent/extensions"
stow --target="$HOME" --ignore='^\.ssh' home

# ────────────────────────────────────────────────────────────────────────────
# 2. Retire old ~/src/ ambient agent-config symlinks
#
# Global agent config lives in each tool's native home-scoped location. If older
# bootstrap runs left parent-directory discovery symlinks under ~/src, remove
# only the symlinks this repo created; leave real dirs or unrelated links alone.
# ────────────────────────────────────────────────────────────────────────────
for link in "$HOME/src/.claude" "$HOME/src/.agents" "$HOME/src/.codex" "$HOME/src/.config"; do
  if [[ -L "$link" ]]; then
    target=$(readlink "$link")
    case "$target" in
      dotfiles/home/.claude|dotfiles/home/.agents|dotfiles/home/.codex|dotfiles/home/.config|*/src/dotfiles/home/.claude|*/src/dotfiles/home/.agents|*/src/dotfiles/home/.codex|*/src/dotfiles/home/.config)
        rm "$link"
        ;;
    esac
  fi
done

# ────────────────────────────────────────────────────────────────────────────
# 3. Systemd user unit symlinks
#
# ~/.config/systemd/user/ is a real directory systemd manages alongside
# *.target.wants/ symlinks; stow can't replace it with a directory symlink.
# Instead, symlink each individual unit file from the dotfiles source.
# Enable + start manually after bootstrap with:
#   systemctl --user enable --now <unit>
# ────────────────────────────────────────────────────────────────────────────
if [[ "$OS_TYPE" != "darwin" ]]; then
  mkdir -p "$HOME/.config/systemd/user"
  for unit in "$DOTFILES"/config/systemd/user/*.service "$DOTFILES"/config/systemd/user/*.timer "$DOTFILES"/config/systemd/user/*.target; do
    [[ -e "$unit" ]] || continue
    ln -sfn "$unit" "$HOME/.config/systemd/user/$(basename "$unit")"
  done
  systemctl --user daemon-reload 2>/dev/null || true
fi

# ────────────────────────────────────────────────────────────────────────────
# 4. Skill dir symlinks
#
# ~/.claude/skills/ and ~/.claude/commands/ live INSIDE ~/.claude/ (auth.json,
# projects/, prompts/, etc. that stow can't fold). Symlink those dirs so every
# entry is dotfile-tracked. Pi and Codex read the same tree via ~/.claude/skills.
# New entries added via `npx skills add` (install.sh) auto-track in dotfiles git.
# ────────────────────────────────────────────────────────────────────────────
ln -sfn "$DOTFILES/home/.claude/skills"   "$HOME/.claude/skills"
ln -sfn "$DOTFILES/home/.claude/commands" "$HOME/.claude/commands"
ln -sfn "$DOTFILES/home/.cursor/mcp.json" "$HOME/.cursor/mcp.json"

if [[ "$OS_TYPE" == "darwin" && -d "$DOTFILES/config/alfred/workflows" ]]; then
  alfred_workflows="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"
  mkdir -p "$alfred_workflows"
  for workflow in "$DOTFILES"/config/alfred/workflows/*; do
    [[ -d "$workflow" ]] || continue
    workflow_link="$alfred_workflows/$(basename "$workflow")"
    if [[ -e "$workflow_link" && ! -L "$workflow_link" ]]; then
      echo "Skipping Alfred workflow $(basename "$workflow"): $workflow_link exists and is not a symlink"
      continue
    fi
    ln -sfn "$workflow" "$workflow_link"
  done

  alfred_local_prefs="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/preferences/local"
  for local_hash in "$alfred_local_prefs"/*; do
    [[ -d "$local_hash" ]] || continue
    mkdir -p "$local_hash/features/clipboard"
    /usr/libexec/PlistBuddy -c 'Add enabled bool true' "$local_hash/features/clipboard/prefs.plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c 'Set enabled true' "$local_hash/features/clipboard/prefs.plist" 2>/dev/null || true
  done
fi

if [ -L "$HOME/.pi/agent/skills" ]; then
  rm "$HOME/.pi/agent/skills"
fi
if [ -d "$HOME/.codex/skills" ] && [ ! -L "$HOME/.codex/skills" ]; then
  rm -rf "$HOME/.codex/skills"
fi

if [[ -d "$BACKUP_DIR" ]]; then
  echo "Backed up pre-existing real files to $BACKUP_DIR"
fi
echo "Bootstrap complete!"
