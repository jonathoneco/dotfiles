# Dotfiles

GNU Stow-managed configs for ~20 apps, deployed to two machines: EndeavourOS (Arch) / Sway and macOS. `bootstrap.sh` branches on `OS_TYPE` for platform-specific packages.

`./bootstrap.sh` is the single entry point — re-runnable, applies stow + the things stow can't handle (individual systemd user unit symlinks and native agent skill directory symlinks).

## Stow Packages

| Package | Source | Target | Contents |
|---|---|---|---|
| config | `config/` | `~/.config/` | 21 app configs (sway, nvim, tmux, zsh, foot, ghostty, waybar, herdr, etc.) |
| bin | `bin/` | `~/.local/bin/` | user scripts (tmux-sessionizer, system-maintenance, etc.) |
| home | `home/` | `~/` | .agents/, .claude/, .codex/, .cursor/, .pi/, .zshenv, .fzfrc |
| applications | `applications/` | `~/.local/share/applications/` | .desktop files (handy, keymapp) |
| marta | `marta/` | `~/` | Marta config under `~/Library/Application Support/org.yanex.marta/` |
| system-bin | `system-bin/` | `/usr/local/bin/` | 4 system scripts (requires sudo stow) |
| etc | `etc/` | `/etc/` | kmonad, qt6 env (requires sudo stow); TLP via drop-in copy (see below) |
| secrets | `secrets/` | — | Not stowed; env var templates (gitignored) |

## Non-stow symlinks (handled by `bootstrap.sh`)

| Symlink | Target | Why not stow |
|---|---|---|
| `~/.config/systemd/user/*.service` | `dotfiles/config/systemd/user/*.service` | `~/.config/systemd/user/` is a real directory systemd manages alongside `*.target.wants/` symlinks; full-directory stow would conflict. Bootstrap iterates the dotfiles source and creates per-file symlinks. |
| `~/.claude/skills` | `dotfiles/home/.claude/skills` | `~/.claude/` is a real runtime directory (auth, projects, prompts) stow can't fold; only the skills farm is dotfile-tracked. Pi reads the same tree via its `settings.json`. |
| `/etc/NetworkManager/conf.d/10-dns-systemd-resolved.conf` | `dotfiles/share/networkmanager/10-dns-systemd-resolved.conf` | Copied by bootstrap so NetworkManager feeds DNS into `systemd-resolved`; bootstrap also enables `systemd-resolved` and points `/etc/resolv.conf` at the resolved stub for Tailscale compatibility. Arch only. |
| `~/.config/herdr/plugins/config/sessionizer/config.toml` | `dotfiles/share/herdr/sessionizer.toml` | Herdr owns `~/.config/herdr/plugins/` for installed plugin code and runtime state, so bootstrap installs Sessionizer and links only its managed config. |
| `/etc/tlp.d/99-dotfiles.conf` | `dotfiles/share/tlp/99-dotfiles.conf` | Pacman owns `/etc/tlp.conf`; drop-in is copied (not symlinked) so TLP does not depend on `$HOME` at boot. |
| `/etc/tlp.d/zzz-dotfiles-saver.conf` | `dotfiles/share/tlp/zzz-dotfiles-saver.conf` | Optional overlay; `bin/tlp-profile saver` installs it (USB autosuspend). Removed by `tlp-profile daily`. |

## Agent harness

**Canonical rules:** `home/.agents/AGENTS.md` — the single global rules file. Harness surfaces consume it without forking: `home/.codex/AGENTS.md` and `home/.pi/agent/AGENTS.md` are symlinks; `home/.claude/CLAUDE.md` is a tracked shim (one `@~/.agents/AGENTS.md` import + a `## Claude-specific` delta section). Never add rules to a harness surface that belong in canonical.

**Global skills:** `home/.agents/skills/` — the single canonical store. Vendored skills are pinned to an upstream SHA recorded in `docs/agent-skills.md`; refresh only via `scripts/refresh-agent-skills.sh` (staged, reviewed — never `npx skills add/update` against the live store). `home/.claude/skills/` is a symlink farm over the store (per-harness curation = which links exist); bootstrap links `~/.claude/skills` to it; Pi reads the same farm via its `settings.json`.

**Per-repo project skills:** live in each project repo (e.g. Wrangle's `.agents/skills/`), never here.

**Codex policy:** `home/.codex/rules/default.rules` is a hand-written seed, deployed seed-if-absent by bootstrap (never overwrites a machine's live file; excluded from stow via `.stow-local-ignore`).

## Config Registry

| App | Config Path | Validation | Depends On | Packages |
|---|---|---|---|---|
| sway | `config/sway/` | `sway -C` | environment.d, foot, waybar, way-displays | sway swayidle swaylock fuzzel mako |
| way-displays | `config/way-displays/` | YAML parse | — | way-displays |
| nvim | `config/nvim/` | `nvim --headless +'qa!'` | mise (PATH shims) | neovim git ripgrep fd |
| tmux | `config/tmux/` | — | zsh | tmux git fzf |
| zsh | `config/zsh/` | `zsh -n .zshrc` | starship, mise, environment.d | zsh starship mise zoxide fzf eza bat |
| foot | `config/foot/` | — | — | foot |
| ghostty | `config/ghostty/` | `ghostty +validate-config` | foot | ghostty |
| waybar | `config/waybar/` | — | sway | waybar brightnessctl pavucontrol |
| starship | `config/starship.toml` | TOML parse | — | starship |
| mise | `config/mise/` | TOML parse | — | mise |
| alacritty | `config/alacritty/` | — | omarchy theme | alacritty |
| kitty | `config/kitty/` | — | omarchy theme | kitty |
| ranger | `config/ranger/` | — | — | ranger |
| zathura | `config/zathura/` | — | — | zathura |
| environment.d | `config/environment.d/` | — | — | systemd |
| fastfetch | `config/fastfetch/` | — | — | fastfetch |
| fontconfig | `config/fontconfig/` | — | — | fontconfig |
| uwsm | `config/uwsm/` | — | sway | uwsm |
| systemd-user | `config/systemd/user/` | `systemd-analyze --user verify <unit>` | mise (PATH for service `Environment=`) | systemd |
| herdr | `config/herdr/config.toml` | TOML parse | sessionizer plugin config in `share/herdr/` | herdr bun fzf |

lazygit is used but has no config in this repo.

### Systemd user units

The `config/systemd/user/` directory holds tracked user services (`.service`, `.timer`). They are symlinked into `~/.config/systemd/user/` by `bootstrap.sh` (per-file, not full-directory — see "Non-stow symlinks" above).

Pattern for adding a new unit:
1. Write the unit at `config/systemd/user/<name>.service`.
2. Run `./bootstrap.sh` (creates the symlink + reloads systemd).
3. Enable + start: `systemctl --user enable --now <name>.service`.

Currently registered:
- `openbrain-mcp.service` — Open Brain MCP Edge Function (local Supabase). Autostarts the personal knowledge base by running `~/src/openbrain/bin/serve`.

## Dependency Graph

```
environment.d/common.conf  (PATH, XDG, DOTFILES, MOZ_ENABLE_WAYLAND)
├── sway/config
│   ├── config.d/*  (default, autostart, input, output, theme, app_defaults)
│   ├── scripts/*   (power_menu, display_layout_editor, window_switcher, etc.)
│   ├── foot        (default terminal, runs as server)
│   ├── waybar      (status bar, launched on sway start)
│   └── mako / swayosd / swayidle / swaylock
├── way-displays/cfg.yaml  (output management daemon, independent of sway)
├── zsh/.zshrc  (sources in order:)
│   ├── config/shell      (history, completion, colors)
│   ├── config/aliases
│   ├── config/functions
│   ├── config/prompt     → starship init
│   ├── config/envs       → sources ~/.local/secrets/secrets.env
│   ├── config/init       → mise activate, zoxide init, fzf
│   └── config/bindings   (interactive only)
├── tmux/tmux.conf
│   ├── config/options.conf      (default-shell = zsh)
│   ├── config/keybindings.conf
│   ├── config/plugins.conf      (TPM: tmux-yank, fzf-url, rose-pine)
│   └── config/colors.conf
└── nvim/init.lua
    ├── lua/config/  (options, keymaps, autocmds, helpers, health, icons, snippets)
    └── lua/plugins/ (21 plugin specs, auto-discovered by lazy.nvim)
```

## Agent Workflow Rules

| After editing | Run |
|---|---|
| sway configs | `sway -C` (or `sway --validate`) |
| shell scripts | `shellcheck -x <file>` |
| zsh config files | `zsh -n <file>` |
| nvim lua files | `nvim --headless +'qa!'` |
| TOML files | `python3 -c "import tomllib; tomllib.load(open('<file>','rb'))"` |
| any config | `./validate.sh` (runs all checks, also in pre-commit hook) |

- Never edit files in `secrets/`
- Stow dry-run: `stow --no --verbose <package>` (from repo root)
- `config/` maps to `~/.config/` via stow
- `bin/` maps to `~/.local/bin/` via stow
- Run `./validate.sh` before committing (also enforced by pre-commit hook)

## Script Locations

| Directory | Target | Notes |
|---|---|---|
| `bin/` | `~/.local/bin/` | User scripts, no .sh extension, detect by shebang |
| `system-bin/` | `/usr/local/bin/` | System scripts, requires sudo |
| `config/sway/scripts/` | `~/.config/sway/scripts/` | Sway helpers (.sh + swayfader.py) |
| `config/waybar/scripts/` | `~/.config/waybar/scripts/` | keyhint.sh |

All shell scripts must pass `shellcheck -x`.

## File Structure

```
dotfiles/
├── install.sh          # Portable installer (Linux/macOS, profiles: minimal/dev)
├── test.sh             # Docker-based integration tests (37 checks)
├── validate.sh         # Fast local validation (<10s, no Docker/sudo)
├── AGENTS.md           # This file (agent instructions)
├── bin/                # → ~/.local/bin/
├── config/             # → ~/.config/
├── home/               # → ~/
│   ├── .agents/        # Canonical agent rules + skill store
│   ├── .claude/        # Claude Code shim, settings, hooks, skill farm
│   ├── .codex/         # Codex config (AGENTS.md symlink, rules seed)
│   └── .pi/            # Pi config (AGENTS.md symlink, settings)
├── applications/       # → ~/.local/share/applications/
├── system-bin/         # → /usr/local/bin/
├── etc/                # → /etc/
└── secrets/            # Not stowed (gitignored)
```
