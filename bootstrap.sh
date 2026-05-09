#!/bin/bash
#
# Idempotent bootstrap for this dotfiles repo.
# Handles stow packages, ~/src/ upward-traversal symlinks, and systemd user
# unit symlinks (the latter two are needed because stow can't fit them).
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
# 2. ~/src/ upward-traversal symlinks
#
# Tools that walk parent directories looking for config (Claude Code → .claude,
# Codex → .codex, etc.) need to find them when working in any project under
# ~/src/. Symlinking the dotfiles home/* dirs into ~/src/ achieves that
# without re-stowing them at multiple levels.
# ────────────────────────────────────────────────────────────────────────────
mkdir -p "$HOME/src"
ln -sfn dotfiles/home/.claude  "$HOME/src/.claude"
ln -sfn dotfiles/home/.agents  "$HOME/src/.agents"
ln -sfn dotfiles/home/.codex   "$HOME/src/.codex"
ln -sfn dotfiles/home/.config  "$HOME/src/.config"

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
for unit in "$DOTFILES"/config/systemd/user/*.service \
            "$DOTFILES"/config/systemd/user/*.timer; do
    ln -sfn "$unit" "$HOME/.config/systemd/user/$(basename "$unit")"
done
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
mkdir -p "$HOME/.claude" "$HOME/.pi/agent"
ln -sfn "$DOTFILES/home/.claude/skills"   "$HOME/.claude/skills"
ln -sfn "$DOTFILES/home/.claude/commands" "$HOME/.claude/commands"
ln -sfn "$DOTFILES/home/.pi/agent/skills" "$HOME/.pi/agent/skills"

echo "Bootstrap complete!"
