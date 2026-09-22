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
# ~/.claude/settings.json and ~/.codex/config.toml are machine-local by design
# (steps 5f and 5b merge or seed them in place), so they are never moved aside
# here: moving a live file before a seed-if-absent step turns the seed into an
# overwrite, which lost a machine's Codex trust pins and MCP servers once.
backup_real_file .pi/agent/settings.json
backup_real_file .pi/agent/extensions/superset-hooks.ts
if [[ "$OS_TYPE" == "darwin" ]]; then
  backup_real_file "Library/Application Support/org.yanex.marta/conf.marco"
  backup_real_file "Library/Application Support/org.yanex.marta/favorites.marco"
fi

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/secrets"
# Herdr owns runtime state under ~/.config/herdr. Create the parent before
# stowing so Stow folds config.toml into this real directory instead of linking
# the entire tracked config/herdr directory and exposing the repo to plugin
# runtime writes.
mkdir -p "$HOME/.config/herdr"
herdr_config="$HOME/.config/herdr/config.toml"
if [[ -f "$herdr_config" && ! -L "$herdr_config" ]]; then
  herdr_backup="${herdr_config}.pre-dotfiles"
  if [[ -e "$herdr_backup" ]]; then
    echo "Refusing to overwrite existing Herdr config backup: $herdr_backup" >&2
    exit 1
  fi
  mv "$herdr_config" "$herdr_backup"
fi
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

mkdir -p "$HOME/.claude" "$HOME/.codex/rules" "$HOME/.pi/agent/extensions"
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
# 4. Herdr runtime config symlink
#
# Herdr owns ~/.config/herdr/plugins/ for installed plugin code and state. Keep
# that runtime directory real and link only the Sessionizer config file into it.
# ────────────────────────────────────────────────────────────────────────────
sessionizer_ready=true
for command in herdr bun fzf; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "WARN: missing Sessionizer dependency '$command' — skipping herdr sessionizer setup" >&2
    sessionizer_ready=false
  fi
done
if [[ "$sessionizer_ready" == "true" ]]; then
  # Ask herdr what it has, but never let the answer take bootstrap down. A
  # herdr whose server outlives a client upgrade exits non-zero on every
  # command, and under set -e that aborted every section below this one —
  # skill links, codex seeds, environment notes — none of which involve herdr.
  # Missing dependencies already warn and skip above; a herdr that cannot
  # answer is the same kind of "cannot set up sessionizer right now".
  if plugin_json=$(herdr plugin list --plugin sessionizer --json 2>&1); then
    if ! grep -q '"plugin_id":"sessionizer"' <<< "$plugin_json"; then
      herdr plugin install andrewchng/herdr-sessionizer --yes
    elif ! grep -q '"enabled":true' <<< "$plugin_json"; then
      herdr plugin enable sessionizer
    fi
  else
    echo "WARN: herdr did not answer — skipping sessionizer plugin setup:" >&2
    printf '%s\n' "$plugin_json" | head -3 >&2
  fi
  # The config link is just paths; it stands whether or not herdr answered.
  mkdir -p "$HOME/.config/herdr/plugins/config/sessionizer"
  ln -sfn "$DOTFILES/share/herdr/sessionizer.toml" \
    "$HOME/.config/herdr/plugins/config/sessionizer/config.toml"
fi

# ────────────────────────────────────────────────────────────────────────────
# 5. Skill dir symlink
#
# ~/.claude/skills/ lives INSIDE ~/.claude/ (auth.json, projects/, prompts/,
# etc. that stow can't fold). Symlink the farm so every entry is
# dotfile-tracked. The farm is the ONLY distribution path: it links into the
# canonical store home/.agents/skills/ (see docs/agent-skills.md). Pi reads
# the same farm via its settings.json.
# ────────────────────────────────────────────────────────────────────────────
ln -sfn "$DOTFILES/home/.claude/skills" "$HOME/.claude/skills"

# Retire the ~/.claude/agents and ~/.claude/commands links. Older stow and
# bootstrap runs pointed them into home/.claude/agents and .../commands, which
# the repo no longer carries, so they dangle. Remove only those links.
for link in "$HOME/.claude/agents" "$HOME/.claude/commands"; do
  if [[ -L "$link" ]]; then
    case "$(readlink "$link")" in
      */dotfiles/home/.claude/agents|*/dotfiles/home/.claude/commands) rm "$link" ;;
    esac
  fi
done

# ────────────────────────────────────────────────────────────────────────────
# 5b. Codex policy seed (seed-if-absent)
#
# default.rules is excluded from stow (.stow-local-ignore): each machine's
# live file accretes local approvals and is machine state, not repo policy.
# Fresh machines get the hand-written seed once; existing files are never
# touched.
# ────────────────────────────────────────────────────────────────────────────
# seed_machine_file <live-path> <repo-seed>: the live file is machine state.
# A legacy stow symlink into the repo converts to a real file with the same
# content (accretion stays on the machine); an absent file gets the repo seed
# once; an existing real file is never touched.
seed_machine_file() {
  local live="$1" seed="$2" resolved
  if [[ -L "$live" ]]; then
    resolved=$(cat "$live")
    rm "$live"
    printf '%s\n' "$resolved" > "$live"
    chmod 0644 "$live"
    echo "Converted $live from symlink to machine-local file"
  elif [[ ! -e "$live" ]]; then
    mkdir -p "$(dirname "$live")"
    install -m 0644 "$seed" "$live"
    echo "Seeded $live"
  fi
}
seed_machine_file "$HOME/.codex/rules/default.rules" "$DOTFILES/home/.codex/rules/default.rules"
# config.toml accretes codex-written machine state (project trust entries), so
# it follows the same contract; the repo keeps only the hand-written seed.
seed_machine_file "$HOME/.codex/config.toml" "$DOTFILES/home/.codex/config.toml"

# Codex's command runner must receive the environment of the Herdr-launched
# process. Reconcile this repo-owned setting in place while preserving the
# machine-local model, trust entries, and any other Codex state in config.toml.
ensure_codex_shell_environment_policy() {
  local config="$1"
  python3 - "$config" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
section = re.search(
    r"(?ms)^\[shell_environment_policy\]\s*\n(?P<body>.*?)(?=^\[|\Z)",
    text,
)

if section is None:
    if text and not text.endswith("\n"):
        text += "\n"
    text += '\n[shell_environment_policy]\ninherit = "all"\n'
else:
    body = section.group("body")
    inherit = re.search(r'(?m)^\s*inherit\s*=\s*[^\n]*$', body)
    if inherit is None:
        replacement = body + 'inherit = "all"\n'
    else:
        replacement = body[:inherit.start()] + 'inherit = "all"' + body[inherit.end():]
    text = text[:section.start("body")] + replacement + text[section.end("body"):]

path.write_text(text)
PY
}
ensure_codex_shell_environment_policy "$HOME/.codex/config.toml"

# Route Codex through CLIProxyAPI on machines that carry its host-local client
# key. Keep the key in the environment and reconcile only the provider settings
# this repository owns; preserve app-written model, trust, plugin, and hook state.
ensure_codex_cli_proxy_provider() {
  local config="$1"
  local key_file="$HOME/.config/cli-proxy-api/client-api-key"

  [[ -r "$key_file" ]] || return 0

  python3 - "$config" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
first_section = re.search(r"(?m)^\[", text)
preamble_end = first_section.start() if first_section else len(text)
preamble = text[:preamble_end]
remainder = text[preamble_end:]
provider_key = re.search(r'(?m)^model_provider\s*=\s*[^\n]*$', preamble)

if provider_key is None:
    model_key = re.search(r'(?m)^model\s*=\s*[^\n]*$', preamble)
    insertion = 'model_provider = "cliproxyapi"\n'
    if model_key is None:
        preamble = insertion + preamble
    else:
        preamble = preamble[:model_key.end()] + "\n" + insertion.rstrip("\n") + preamble[model_key.end():]
else:
    preamble = preamble[:provider_key.start()] + 'model_provider = "cliproxyapi"' + preamble[provider_key.end():]

text = preamble + remainder
provider_block = '''[model_providers.cliproxyapi]
name = "CLIProxyAPI"
base_url = "https://cli-proxy-api.tail630c10.ts.net/v1"
wire_api = "responses"
env_key = "CLIPROXYAPI_API_KEY"
'''
section = re.search(
    r"(?ms)^\[model_providers\.cliproxyapi\]\s*\n.*?(?=^\[|\Z)",
    text,
)
if section is None:
    if text and not text.endswith("\n"):
        text += "\n"
    text += "\n" + provider_block
else:
    text = text[:section.start()] + provider_block + text[section.end():]

path.write_text(text)
PY
}
ensure_codex_cli_proxy_provider "$HOME/.codex/config.toml"

# ────────────────────────────────────────────────────────────────────────────
# 5c. Codex git-guardrail hook (idempotent merge)
#
# Codex PreToolUse speaks the same contract as Claude Code (JSON on stdin,
# exit 2 blocks), so the one guardrail script covers both harnesses.
# ~/.codex/hooks.json is machine state (other tools append their own hooks),
# so merge the entry in with jq rather than shipping the file; re-running is a
# no-op once the entry exists. Codex prompts once to trust the hook.
# ────────────────────────────────────────────────────────────────────────────
codex_hooks="$HOME/.codex/hooks.json"
guardrail_cmd="$HOME/.claude/hooks/git-guardrail.sh"
if command -v jq >/dev/null 2>&1; then
  [[ -s "$codex_hooks" ]] || printf '{"hooks":{}}\n' > "$codex_hooks"
  if ! jq -e --arg cmd "$guardrail_cmd" \
    '[.hooks.PreToolUse[]?.hooks[]?.command] | index($cmd)' "$codex_hooks" >/dev/null; then
    tmp=$(mktemp)
    jq --arg cmd "$guardrail_cmd" \
      '.hooks.PreToolUse = ((.hooks.PreToolUse // []) + [{hooks: [{type: "command", command: $cmd, timeout: 60}]}])' \
      "$codex_hooks" > "$tmp" && mv "$tmp" "$codex_hooks"
    echo "Merged git-guardrail into ~/.codex/hooks.json (trust it on next codex run)"
  fi
  # Keep the file true to the current hook set: the guardrail gets a 60 s
  # limit (a 10 s hook that times out under load runs the command unchecked),
  # and the retired Superset notifier is dropped wherever it was wired, along
  # with any matcher group or event left empty by that removal.
  tmp=$(mktemp)
  jq --arg cmd "$guardrail_cmd" '
    .hooks |= with_entries(
      .value |= (map(
        .hooks |= (map(select(.command | test("\\.superset/hooks/notify\\.sh") | not))
                   | map(if .command == $cmd then .timeout = 60 else . end))
      ) | map(select((.hooks | length) > 0)))
    ) | .hooks |= with_entries(select((.value | length) > 0))' \
    "$codex_hooks" > "$tmp" && mv "$tmp" "$codex_hooks"
else
  echo "WARN: jq missing — codex git-guardrail hook not merged into $codex_hooks"
fi

# ────────────────────────────────────────────────────────────────────────────
# 5c'. Codex OpenBrain memory hooks (idempotent merge)
#
# The openbrain clone carries four Codex wrappers (recall on each prompt,
# recall again after a compaction, and detached digests before compaction and
# at session end). Claude's copies are symlinked from home/.claude/hooks; Codex
# has no stowable hooks directory, so the entries merge into ~/.codex/hooks.json
# the way the guardrail does, appended so Codex's per-position trust survives.
# Codex skips a new handler until it is reviewed with /hooks in the TUI.
# ────────────────────────────────────────────────────────────────────────────
ob_codex_hooks="$HOME/src/openbrain/integrations/agent-memory-client/hooks/codex"
if [[ -d "$ob_codex_hooks" ]] && command -v jq >/dev/null 2>&1; then
  ob_merge_hook() { # event wrapper timeout [matcher]
    local event=$1 cmd="sh \"$ob_codex_hooks/$2\"" timeout=$3 matcher=${4:-}
    if ! jq -e --arg cmd "$cmd" --arg ev "$event" \
      '[.hooks[$ev][]?.hooks[]?.command] | index($cmd)' "$codex_hooks" >/dev/null; then
      tmp=$(mktemp)
      jq --arg cmd "$cmd" --arg ev "$event" --argjson t "$timeout" --arg m "$matcher" \
        '.hooks[$ev] = ((.hooks[$ev] // []) + [(if $m == "" then {} else {matcher: $m} end)
           + {hooks: [{type: "command", command: $cmd, timeout: $t}]}])' \
        "$codex_hooks" > "$tmp" && mv "$tmp" "$codex_hooks"
      echo "Merged OpenBrain $event hook into ~/.codex/hooks.json (review it with /hooks in codex)"
    fi
  }
  ob_merge_hook UserPromptSubmit user-prompt-submit.sh 20
  ob_merge_hook SessionStart session-start.sh 20 '^compact$'
  ob_merge_hook PreCompact pre-compact.sh 30
  ob_merge_hook SessionEnd session-end.sh 3
elif [[ ! -d "$ob_codex_hooks" ]]; then
  echo "NOTE: ~/src/openbrain not cloned; Codex OpenBrain hooks not merged"
fi

# ────────────────────────────────────────────────────────────────────────────
# 5c''. Codex trust for repo-owned hooks
#
# Codex runs a hook only after a person approves it in the TUI, and it pins that
# approval as a hash of the hook's config entry (event, matcher, command,
# timeout, async), not of the script. So any edit to the entry, a timeout bump
# included, silently stops the hook until it is re-approved on every machine.
# For hooks the repos own (the dotfiles guardrail, the OpenBrain wrappers, and
# Wrangle's two), bootstrap writes the pin itself: those repos already run as
# the user on every machine, so the TUI step added no check. Anything else in
# the hooks file keeps the manual approval. The hash matches Codex's
# hook_hash: a key-sorted, compact JSON of the normalized entry.
# ────────────────────────────────────────────────────────────────────────────
if command -v python3 >/dev/null 2>&1; then
  OB_CODEX_HOOKS="$ob_codex_hooks" python3 - "$HOME/.codex/config.toml" \
    "$HOME/.codex/hooks.json" "$HOME/src/wrangle/.codex/hooks.json" <<'PY'
import hashlib, json, os, re, sys
cfg_path, *hook_files = sys.argv[1:]
owned_prefixes = (
    os.path.expanduser("~/.claude/hooks/git-guardrail.sh"),
    os.environ.get("OB_CODEX_HOOKS", "/nonexistent"),
    "scripts/guard-agent-command.sh",
    "scripts/docs-ping-hook.sh",
)
def event_key(name):
    return re.sub(r"(?<!^)(?=[A-Z])", "_", name).lower()
def canonical(o):
    if isinstance(o, dict): return {k: canonical(o[k]) for k in sorted(o)}
    if isinstance(o, list): return [canonical(x) for x in o]
    return o
def hook_hash(event, group, hook):
    handler = {"type": hook.get("type", "command"), "command": hook["command"],
               "timeout": hook["timeout"], "async": hook.get("async", False)}
    for k in ("commandWindows", "statusMessage", "additionalContextLimit"):
        if k in hook: handler[k] = hook[k]
    identity = {"event_name": event_key(event), "hooks": [handler]}
    if group.get("matcher") is not None: identity["matcher"] = group["matcher"]
    return "sha256:" + hashlib.sha256(json.dumps(canonical(identity), separators=(",", ":")).encode()).hexdigest()
pins = {}
for hf in hook_files:
    if not os.path.isfile(hf): continue
    data = json.load(open(hf))
    for event, groups in data.get("hooks", {}).items():
        for gi, group in enumerate(groups):
            for hi, hook in enumerate(group.get("hooks", [])):
                cmd = hook.get("command", "")
                if not any(cmd.startswith(p) or f'"{p}' in cmd for p in owned_prefixes): continue
                if "timeout" not in hook: continue  # Codex fills a default we do not model; leave for the TUI
                pins[f"{hf}:{event_key(event)}:{gi}:{hi}"] = hook_hash(event, group, hook)
if not os.path.isfile(cfg_path): sys.exit(0)
text = open(cfg_path).read()
changed = []
for key, digest in pins.items():
    header = f'[hooks.state."{key}"]'
    pat = re.compile(re.escape(header) + r"\ntrusted_hash = \"[^\"]*\"")
    line = f'{header}\ntrusted_hash = "{digest}"'
    if pat.search(text):
        if pat.search(text).group(0) != line:
            text = pat.sub(line, text, count=1); changed.append(key)
    else:
        if "[hooks.state]" not in text: text = text.rstrip("\n") + "\n\n[hooks.state]\n"
        text = text.rstrip("\n") + "\n\n" + line + "\n"; changed.append(key)
if changed:
    open(cfg_path, "w").write(text)
    for k in changed: print(f"Pinned Codex trust for {k}")
PY
fi

# ────────────────────────────────────────────────────────────────────────────
# 5d. Machine environment notes (seed-if-absent)
#
# ~/.agents/AGENTS.md points at this file for machine specifics (package
# manager, WM, terminal, notifier), so always-loaded rules stay OS-neutral and
# each machine reads only its own facts. Seeded once per machine with that
# machine's row; accretes locally, never overwritten.
# ────────────────────────────────────────────────────────────────────────────
env_notes="$HOME/.local/state/agent-notes/environment.md"
if [[ ! -e "$env_notes" ]]; then
  mkdir -p "$HOME/.local/state/agent-notes"
  chmod 700 "$HOME/.local/state/agent-notes"
  if [[ "$OS_TYPE" == "darwin" ]]; then
    cat > "$env_notes" <<'ENVEOF'
# This machine (macOS)

- Packages: Homebrew.
- Aerospace WM, Ghostty terminal.
- Notifications: `terminal-notifier`.
ENVEOF
  else
    cat > "$env_notes" <<'ENVEOF'
# This machine (Arch / EndeavourOS)

- Packages: AUR-first — check `paru -Ss <pkg>` before source builds.
- Sway WM, foot terminal.
- Notifications: `notify-send` (swaync handles delivery).
ENVEOF
  fi
  echo "Seeded $env_notes"
fi

# ────────────────────────────────────────────────────────────────────────────
# 5f. Claude Code settings (repo-owned keys merged into a machine-local file)
#
# /model writes the default model into ~/.claude/settings.json, and that choice
# is per machine and changes often, so the live file cannot be a link into the
# repo. It is a real file: seeded from home/.claude/settings.json on a new
# machine, and on every run every top-level key the repo carries is written
# over the live value, except the machine-local keys below, which the live file
# keeps. Keys only the live file has are left alone. A settings change lands on
# a machine when this step runs there.
# ────────────────────────────────────────────────────────────────────────────
claude_settings_repo="$DOTFILES/home/.claude/settings.json"
claude_settings_live="$HOME/.claude/settings.json"
claude_machine_keys='["model"]'
if command -v jq >/dev/null 2>&1; then
  if [[ -L "$claude_settings_live" ]]; then
    # A link from an earlier stow: keep what it pointed at, as a real file.
    tmp=$(mktemp); cat "$claude_settings_live" > "$tmp"
    rm "$claude_settings_live"; mv "$tmp" "$claude_settings_live"
  fi
  if [[ ! -s "$claude_settings_live" ]]; then
    cp "$claude_settings_repo" "$claude_settings_live"
    echo "Seeded ~/.claude/settings.json from the repo"
  else
    tmp=$(mktemp)
    jq --slurpfile repo "$claude_settings_repo" --argjson keep "$claude_machine_keys" '
      reduce ($repo[0] | keys[]) as $k (.;
        if ($keep | index($k)) then . else .[$k] = $repo[0][$k] end)' \
      "$claude_settings_live" > "$tmp" && mv "$tmp" "$claude_settings_live"
  fi
else
  echo "WARN: jq missing — ~/.claude/settings.json not merged from the repo"
fi

# ────────────────────────────────────────────────────────────────────────────
# 5e. OpenBrain memory hooks (prerequisite check)
#
# settings.json wires UserPromptSubmit, SessionEnd and PreCompact to
# ~/.claude/hooks/openbrain-*.sh, which stow places as symlinks into
# ~/src/openbrain/integrations/agent-memory-client/. Without that checkout the
# links dangle and every prompt runs a missing file. Without the key the hooks
# run and do nothing, by design — a machine with no OpenBrain is never broken
# by them. Neither is installable from here (the repo is a clone, the key is a
# secret), so this reports rather than fixes.
# ────────────────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/src/openbrain" ]]; then
  echo "WARN: ~/src/openbrain missing — OpenBrain memory hooks will dangle."
  echo "      git clone https://github.com/jonathoneco/openbrain ~/src/openbrain"
elif [[ ! -e "$HOME/.config/openbrain/client.env" ]]; then
  echo "NOTE: ~/.config/openbrain/client.env absent — OpenBrain recall and"
  echo "      write-back stay inert on this machine. See secrets/README.md."
fi

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

if [[ -d "$BACKUP_DIR" ]]; then
  echo "Backed up pre-existing real files to $BACKUP_DIR"
fi
echo "Bootstrap complete!"
