# Dotfiles

GNU Stow-managed configs, deployed to two machines: EndeavourOS (Arch) / Sway and macOS. `bootstrap.sh` branches on `OS_TYPE` for platform-specific packages. The Sway side (window manager, bar, compositor daemons) has no macOS equivalent; the Mac side instead uses AeroSpace (WM), Alfred (launcher/workflows), and Marta (file manager) — see the Config Registry and the macOS section below for how those wire up.

`./bootstrap.sh` is the re-run entry point: re-runnable, applies stow plus the things stow can't handle (per-file systemd user unit symlinks and native agent skill directory symlinks). `install.sh` is the fresh-machine installer: it clones the repo, installs system/CLI packages for the chosen profile, then stows. Run `install.sh` once on a new machine; run `bootstrap.sh` afterward (and on every machine whenever config changes) to re-apply links.

## Stow Packages

| Package | Source | Target | Contents |
|---|---|---|---|
| config | `config/` | `~/.config/` | app configs (sway, nvim, tmux, zsh, foot, ghostty, waybar, herdr, aerospace, kanata, etc.) — see the Config Registry for the full list |
| bin | `bin/` | `~/.local/bin/` | user scripts (tmux-sessionizer, system-maintenance, aerospace-*, etc.) |
| home | `home/` | `~/` | .agents/, .claude/, .codex/, .pi/, .zshenv, .fzfrc |
| applications | `applications/` | `~/.local/share/applications/` | .desktop files (handy, keymapp) |
| marta | `marta/` | `~/` | macOS only. Marta config under `~/Library/Application Support/org.yanex.marta/` |
| system-bin | `system-bin/` | `~/.local/bin/` | Linux only. 4 system scripts, stowed by `bootstrap.sh` with no sudo |
| etc | `etc/` | `/etc/` | environment.d overrides, qt6 env, a profile.d script (requires sudo stow); also carries `etc/kmonad/laptop.kbd`, kept tracked but superseded by the `kanata` config package; TLP via drop-in copy (see below) |
| secrets | `secrets/` | `~/.local/secrets/` | stowed by `bootstrap.sh`; only `README.md` is tracked, everything else is gitignored. zsh sources `~/.local/secrets/secrets.env` if present |

## Non-stow symlinks (handled by `bootstrap.sh`)

| Symlink | Target | Why not stow |
|---|---|---|
| `~/.config/systemd/user/*.service` | `dotfiles/config/systemd/user/*.service` | `~/.config/systemd/user/` is a real directory systemd manages alongside `*.target.wants/` symlinks; full-directory stow would conflict. Bootstrap iterates the dotfiles source and creates per-file symlinks. |
| `~/.claude/settings.json` | `dotfiles/home/.claude/settings.json` | A real file, not a link: `/model` writes the default model into it, and that choice is per machine. Bootstrap step 5f seeds it once and, on every run, overwrites each repo-owned top-level key while leaving `model` alone; the repo copy carries no `model` key. `validate.sh --deployed` reports drift on the repo-owned keys. |
| `~/.claude/skills` | `dotfiles/home/.claude/skills` | `~/.claude/` is a real runtime directory (auth, projects, prompts) stow can't fold; only the skills farm is dotfile-tracked. Pi reads the same tree via its `settings.json`. |
| `/etc/NetworkManager/conf.d/10-dns-systemd-resolved.conf` | `dotfiles/share/networkmanager/10-dns-systemd-resolved.conf` | Copied by bootstrap so NetworkManager feeds DNS into `systemd-resolved`; bootstrap also enables `systemd-resolved` and points `/etc/resolv.conf` at the resolved stub for Tailscale compatibility. Arch only. |
| `/etc/systemd/resolved.conf.d/90-garden-pad-no-multicast.conf` | `dotfiles/share/systemd-resolved/90-garden-pad-no-multicast.conf` | garden-pad only. Jon installs this root-owned drop-in by hand to turn off LLMNR and mDNS; it is not part of bootstrap. |
| `~/.config/herdr/plugins/config/sessionizer/config.toml` | `dotfiles/share/herdr/sessionizer.toml` | Herdr owns `~/.config/herdr/plugins/` for installed plugin code and runtime state, so bootstrap installs Sessionizer and links only its managed config. |
| `/etc/tlp.d/99-dotfiles.conf` | `dotfiles/share/tlp/99-dotfiles.conf` | Pacman owns `/etc/tlp.conf`; drop-in is copied (not symlinked) so TLP does not depend on `$HOME` at boot. |
| `/etc/tlp.d/zzz-dotfiles-saver.conf` | `dotfiles/share/tlp/zzz-dotfiles-saver.conf` | Optional overlay; `bin/tlp-profile saver` installs it (USB autosuspend). Removed by `tlp-profile daily`. |

## macOS

Most of this doc (the Config Registry's "Linux only" rows, the Dependency Graph, systemd units, and "Script Locations") describes the Sway/EndeavourOS machine. On macOS, `bootstrap.sh`'s darwin branch skips sway, waybar, foot, uwsm, environment.d, systemd, way-displays, and system-bin entirely, and instead:

- Stows `marta` (file manager) to `~/Library/Application Support/org.yanex.marta/`.
- Links each `config/alfred/workflows/*` entry into `~/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/` (not stowed — Alfred owns that directory and stow's tree-folding would conflict with its own writes).
- Stows the `config` package as usual, which covers `aerospace` (window manager, the Sway equivalent) and `kanata` (key remapping).
- `bin/` also carries Mac-only scripts: `aerospace-alfred-windows`, `aerospace-focus-or-launch`, `aerospace-scratch-note`, `aerospace-summon-wispr-flow`, `aerospace-workspace-cycle`, `ghostty-theme`, `macos-screenshot`, `wispr-flow-position-status`. They no-op or are simply unused on Linux.

## Agent harness

**Canonical rules:** `home/.agents/AGENTS.md` — the single global rules file. Every harness surface is a symlink to it, so there is one copy and no forks: `home/.claude/CLAUDE.md`, `home/.codex/AGENTS.md`, and `home/.pi/agent/AGENTS.md`. `validate.sh` fails if any of them stops being a resolving symlink. Rules go in canonical; giving one harness its own file means deliberately breaking its symlink.

**Global skills:** `home/.agents/skills/` — the single canonical store. Vendored skills are pinned to an upstream SHA recorded in `docs/agent-skills.md`; refresh only via `scripts/refresh-agent-skills.sh` (staged, reviewed — never `npx skills add/update` against the live store). `home/.claude/skills/` is a symlink farm over the store (per-harness curation = which links exist); bootstrap links `~/.claude/skills` to it; Pi reads the same farm via its `settings.json`.

**Per-repo project skills:** live in each project repo (e.g. Wrangle's `.agents/skills/`), never here.

**OpenBrain memory:** three of the hooks wired in `home/.claude/settings.json` are OpenBrain's — `UserPromptSubmit` → `openbrain-user-prompt-submit.sh` (recall), `SessionEnd` → `openbrain-session-end.sh` and `PreCompact` → `openbrain-pre-compact.sh` (write-back). They live at `home/.claude/hooks/openbrain-*.sh`, symlinks into `~/src/openbrain/integrations/agent-memory-client/hooks/claude-code/`. The repo carries the wiring and the pointers; the client code comes with that clone and the key is machine-local at `~/.config/openbrain/client.env` (see `secrets/README.md`). `bootstrap.sh` step 5e reports either one missing, and `validate.sh` fails on the dangling symlinks a missing clone leaves behind. Runs on the Mac and garden-pad. Codex gets the same four hooks from the clone's `hooks/codex/` set, merged into `~/.codex/hooks.json` by bootstrap step 5c' and reviewed once with `/hooks` in the TUI. Codex runs a hook only once approved, and pins the approval as a hash of the hook's config entry, so any edit to an entry silently stops that hook; bootstrap step 5c'' writes the pin for the hooks the repos own (the guardrail, the OpenBrain wrappers, Wrangle's two), and anything else keeps the `/hooks` approval. The hooks are the global half; the OpenBrain MCP servers are not stowed. `open-brain` (capture, search) is added at user scope by hand with `claude mcp add --scope user`, and the tasks/projects servers stay local to the personal-agent checkout — the split and the command are in `personal-agent/knowledge/personal-agent/systems/openbrain.md`.

**Other Claude Code hooks:** `home/.claude/settings.json` also wires `git-guardrail.sh` (`PreToolUse` on `Bash`, blocks destructive git commands), `herdr-agent-state.sh` (`SessionStart`, reports agent state to Herdr), and `skills-staleness-nudge.sh` (`SessionStart`, flags a stale skill farm). `validate.sh` has a guardrail test table covering these.

**Codex policy:** `home/.codex/rules/default.rules` is a hand-written seed, deployed seed-if-absent by bootstrap (never overwrites a machine's live file; excluded from stow via `.stow-local-ignore`).

## Config Registry

The Validation column is a manual command to run after editing that app's config, not a step `validate.sh` runs on its own — see "Agent Workflow Rules" below for what `validate.sh` actually checks.

| App | Config Path | Validation | Depends On | Packages |
|---|---|---|---|---|
| sway | `config/sway/` | `sway -C` | environment.d, foot, waybar, way-displays | Linux only. sway swayidle swaylock fuzzel mako |
| way-displays | `config/way-displays/` | manual YAML parse | — | Linux only. way-displays |
| nvim | `config/nvim/` | `nvim --headless +'qa!'` | mise (PATH shims) | neovim git ripgrep fd |
| tmux | `config/tmux/` | — | zsh | tmux git fzf |
| zsh | `config/zsh/` | `zsh -n .zshrc` | starship, mise, environment.d | zsh starship mise zoxide fzf eza bat |
| foot | `config/foot/` | — | — | Linux only. foot |
| ghostty | `config/ghostty/` | `ghostty +validate-config` | foot (Linux); default terminal on macOS | ghostty |
| waybar | `config/waybar/` | — | sway | Linux only. waybar brightnessctl pavucontrol |
| starship | `config/starship.toml` | TOML parse | — | starship |
| mise | `config/mise/` | TOML parse | — | mise |
| alacritty | `config/alacritty/` | — | imports `~/.config/omarchy/current/theme/...`, a path that exists only on an Omarchy Linux install, not on this repo's Mac or vanilla-Arch machines | alacritty |
| kitty | `config/kitty/` | — | same omarchy theme import as alacritty; `bin/launch-note` still execs kitty | kitty |
| ranger | `config/ranger/` | — | — | ranger |
| zathura | `config/zathura/` | — | — | zathura |
| environment.d | `config/environment.d/` | — | — | Linux only. systemd |
| fastfetch | `config/fastfetch/` | — | calls `omarchy-version` in its ASCII-art config, same caveat as alacritty/kitty | fastfetch |
| fontconfig | `config/fontconfig/` | — | — | fontconfig |
| uwsm | `config/uwsm/` | — | sway | Linux only. uwsm |
| systemd-user | `config/systemd/user/` | manual `systemd-analyze --user verify <unit>` | mise (PATH for service `Environment=`) | Linux only. systemd |
| herdr | `config/herdr/config.toml` | TOML parse | sessionizer plugin config in `share/herdr/` | herdr bun fzf |
| lazygit | `config/lazygit/config.yml` | manual YAML parse | `bin/osc52copy` | lazygit |
| aerospace | `config/aerospace/aerospace.toml` | TOML parse (`validate.sh`) | — | macOS only. aerospace |
| alfred | `config/alfred/workflows/` | — | linked into `~/Library/Application Support/Alfred/...` by `bootstrap.sh`, not stowed | macOS only. Alfred (paid license) |
| kanata | `config/kanata/kanata.kbd` | `kanata --check` (`validate.sh`) | — | kanata |
| cmux | `config/cmux/` | — | `CMUX_REAL_ZDOTDIR` in zsh | cmux |
| agent-dashboard | `config/agent-dashboard/` | — | — | — |
| nix | `config/nix/` | — | — | nix |
| opencode | `config/opencode/` | — | — | opencode |
| tmux-sessionizer | `config/tmux-sessionizer/` | — | tmux | — |
| wireplumber | `config/wireplumber/` | — | — | Linux only. wireplumber |
| codex-flags.conf | `config/codex-flags.conf` | — | loose file, not a directory | — |
| mimeapps.list | `config/mimeapps.list` | — | loose file, not a directory | Linux only. |

`config/lazygit/config.yml` routes copies through `bin/osc52copy`, which hands
the text to `tmux set-buffer -w` so it reaches the outer terminal over OSC 52.
Direct escape sequences do not escape a `display-popup`, which is where lazygit
usually runs.

Ghostty's `theme` line in `config/ghostty/config.ghostty` is the one place a
terminal theme is chosen. Herdr uses its `terminal` theme and fzf uses ANSI
color names, so both draw with Ghostty's palette. Neovim
(`config/nvim/lua/plugins/theme.lua`) asks the terminal for its background,
foreground and ANSI colors 1-6 at startup and on focus, and builds a mini.hues
scheme from them; SSH sessions get the Mac's colors the same way. Herdr's
`prefix+t` opens `bin/ghostty-theme`, a picker that rewrites that line and
reloads Ghostty on every highlighted theme, so the change shows live. Its tabs
are Favorites (`config/ghostty/favorite-themes`, ctrl-f toggles), Adaptive,
Popular, Dark, Light and All. Themes listed in `config/ghostty/theme-pairs`
have a light/dark partner; previewing or keeping one writes
`light:…,dark:…`, so Ghostty shows the half that matches macOS appearance and
switches with it. Adaptive lists each pair once. foot, cmux's
pane borders, tmux's rose-pine status bar and the Sway desktop keep their own
colors.

### Systemd user units

The `config/systemd/user/` directory holds tracked user units (`.service`, `.timer`, `.target`). They are symlinked into `~/.config/systemd/user/` by `bootstrap.sh` (per-file, not full-directory — see "Non-stow symlinks" above).

Pattern for adding a new unit:
1. Write the unit at `config/systemd/user/<name>.service`.
2. Run `./bootstrap.sh` (creates the symlink + reloads systemd).
3. Enable + start: `systemctl --user enable --now <name>.service`.

Currently tracked:
- `autotiling.service`
- `openbrain-mcp.service` — runs `~/src/openbrain/bin/serve`, which starts a local Supabase stack. OpenBrain's memory client now points at hosted Supabase (`secrets/README.md`, `personal-agent/knowledge/personal-agent/systems/openbrain.md`), so whether this unit is still enabled on any machine is unverified from this repo — check the machine before relying on it.
- `swayfader.service`
- `way-displays.service`
- `sway-session.target`

## Dependency Graph

```
environment.d/  (common.conf: PATH, XDG, DOTFILES, MOZ_ENABLE_WAYLAND; fcitx.conf: input method env)
├── sway/config
│   ├── config.d/*  (default, autostart_applications, input, output, theme, application_defaults, scratchpad)
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
│   └── config/plugins.conf      (TPM: tmux-yank, rose-pine; tmux-fzf-url is commented out, replaced by `bin/tmux-open`)
└── nvim/init.lua
    ├── lua/config/  (options, keymaps, autocmds, helpers, health, icons, snippets)
    └── lua/plugins/ (one spec file per plugin/group, auto-discovered by lazy.nvim)
```

## Agent Workflow Rules

| After editing | Run |
|---|---|
| sway configs | `sway -C` (or `sway --validate`) |
| shell scripts | `shellcheck -x <file>` |
| zsh config files | `zsh -n <file>` |
| nvim lua files | `nvim --headless +'qa!'` |
| TOML files | `python3 -c "import tomllib; tomllib.load(open('<file>','rb'))"` |
| any config | `./validate.sh` (runs shellcheck, config parses/loads, and the harness symlink checks; it does not run a YAML parse or `systemd-analyze` step) |

- Never edit files in `secrets/`
- Stow dry-run: `stow --no --verbose <package>` (from repo root)
- `config/` maps to `~/.config/` via stow
- `bin/` maps to `~/.local/bin/` via stow
- Run `./validate.sh` before committing. `.githooks/pre-commit` (tracked) runs it automatically once `core.hooksPath` is set to `.githooks` — `install.sh` sets that when `.githooks/` exists; on a checkout that only ever ran `bootstrap.sh`, set it once by hand with `git config core.hooksPath .githooks`.

## Script Locations

| Directory | Target | Notes |
|---|---|---|
| `bin/` | `~/.local/bin/` | User scripts, no .sh extension, detect by shebang |
| `system-bin/` | `~/.local/bin/` | Linux only. System scripts, stowed by `bootstrap.sh` with no sudo |
| `config/sway/scripts/` | `~/.config/sway/scripts/` | Sway helpers (.sh + swayfader.py) |
| `config/waybar/scripts/` | `~/.config/waybar/scripts/` | keyhint.sh |

All shell scripts must pass `shellcheck -x`.

## File Structure

```
dotfiles/
├── bootstrap.sh        # Re-run entry point: stow + non-stow symlinks
├── install.sh          # Fresh-machine installer (Linux/macOS, profiles: minimal/dev)
├── test.sh             # Smoke-tests install.sh on Docker (Linux) and Tart (macOS VM)
├── validate.sh         # Fast local validation (<10s, no Docker/sudo)
├── AGENTS.md           # This file (agent instructions; home/.claude/CLAUDE.md symlinks here)
├── ONBOARDING.md        # tmux/nvim/zsh keybinding tutorial for a new machine
├── bin/                # → ~/.local/bin/
├── config/             # → ~/.config/
├── home/               # → ~/
│   ├── .agents/        # Canonical agent rules + skill store
│   ├── .claude/        # Claude Code rules symlink, settings, hooks, skill farm
│   ├── .codex/         # Codex config (AGENTS.md symlink, rules seed)
│   └── .pi/            # Pi config (AGENTS.md symlink, settings)
├── applications/       # → ~/.local/share/applications/
├── marta/              # → ~/ (macOS only, Marta file manager config)
├── system-bin/         # → ~/.local/bin/ (Linux only)
├── etc/                # → /etc/
├── secrets/            # → ~/.local/secrets/ (only README.md tracked; rest gitignored)
├── share/              # Non-stow assets bootstrap copies or links (networkmanager, tlp, herdr sessionizer config)
├── scripts/            # Repo maintenance scripts (e.g. refresh-agent-skills.sh)
├── docs/               # agent-skills.md (vendoring manifest) — everything else moved to
│                       # knowledge/dotfiles/ in personal-agent; see its repo-map.md
├── .githooks/          # pre-commit runs ./validate.sh
└── skills-lock.json    # Pins the vendored skill SHAs referenced by docs/agent-skills.md
```
