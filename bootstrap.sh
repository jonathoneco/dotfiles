#!/bin/bash
#
# Idempotent bootstrap for this dotfiles repo.
# Handles stow packages, systemd user unit symlinks, and native agent skill
# directory symlinks that stow can't fit.
#
# Re-runnable: existing symlinks are replaced with `ln -sfn`.

set -e
shopt -s nullglob

DOTFILES=~/src/dotfiles

# ────────────────────────────────────────────────────────────────────────────
# 1. Stow packages
# ────────────────────────────────────────────────────────────────────────────
cd "$DOTFILES"
stow --target="$HOME/.config" config
stow --target="$HOME/.local/bin" bin
stow --target="$HOME/.local/bin" system-bin
stow --target="$HOME/.local/secrets" secrets
stow --target="$HOME/.local/share/applications/" applications
sudo stow --target="/etc" etc
stow --target="$HOME" home

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
mkdir -p "$HOME/.config/systemd/user"
systemctl --user daemon-reload 2>/dev/null || true

# ────────────────────────────────────────────────────────────────────────────
# 4. Skill dir symlinks
#
# ~/.claude/skills/ and ~/.pi/agent/skills/ live INSIDE real dirs (~/.claude/
# and ~/.pi/agent/ contain auth.json, projects/, prompts/, etc. that stow
# can't fold). Symlink the skill dirs themselves so every entry under them
# is dotfile-tracked. New entries added via `npx skills add` (install.sh)
# auto-track in dotfiles git.
# ────────────────────────────────────────────────────────────────────────────
mkdir -p "$HOME/.claude" "$HOME/.pi/agent" "$HOME/.cursor"
ln -sfn "$DOTFILES/home/.claude/skills"   "$HOME/.claude/skills"
ln -sfn "$DOTFILES/home/.claude/commands" "$HOME/.claude/commands"
ln -sfn "$DOTFILES/home/.pi/agent/skills" "$HOME/.pi/agent/skills"
ln -sfn "$DOTFILES/home/.cursor/mcp.json" "$HOME/.cursor/mcp.json"

echo "Bootstrap complete!"
