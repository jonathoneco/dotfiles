# Herdr configuration deep dive

Date: 2026-07-14. Scope: Herdr 0.7.3 on Apple silicon, compared with the current [Herdr config](../../config/herdr/config.toml) and the prior [tmux options](../../config/tmux/config/options.conf), [keybindings](../../config/tmux/config/keybindings.conf), and [plugins](../../config/tmux/config/plugins.conf). Claims below use Herdr's official docs only.

## Bottom line

The port kept familiar tmux keys, but it disables several of Herdr's differentiators: the workspace/session navigator, native worktrees, scrollback-in-editor, remote image paste, agent-state integrations, and background-attention UI. Keep the tmux muscle memory, but restore these Herdr-native paths on non-conflicting keys. Herdr's model is *session → workspaces → tabs → panes*, and its sidebar tracks all workspaces, panes, and detected agents; this is richer than tmux's status line rather than a replacement to suppress. [Concepts](https://herdr.dev/docs/concepts/) · [UI and sidebar](https://herdr.dev/docs/configuration/#ui-and-sidebar)

## Recommendations now

| Capability | Current port | Proposal | Why / source |
| --- | --- | --- | --- |
| Workspace + session navigation | `goto` and `workspace_picker` are disabled to reserve `prefix+g` and `prefix+w` for lazygit and scratch shell. | Restore them on free keys: `goto = "prefix+f"`, `workspace_picker = "prefix+shift+f"`, `previous_workspace = "prefix+shift+left"`, `next_workspace = "prefix+shift+right"`, and `switch_workspace = "prefix+shift+1..9"`. | Native navigators and indexed workspace jumps are specifically provided for switching project work, rather than opening another fuzzy-finder pane. [Configuration](https://herdr.dev/docs/configuration/#keybindings) · [Config reference](https://herdr.dev/docs/config-reference/) |
| Native worktrees | `new_worktree` is disabled; `prefix+shift+g` only invokes the third-party Sessionizer action. | Prefer native creation at `prefix+shift+g`; add `open_worktree = "prefix+shift+o"`; retain Sessionizer's project picker at `prefix+ctrl+s`. Set `[worktrees] directory = "~/src/worktrees"` only if that is the desired checkout root. | Herdr creates/open/groups worktrees as first-class workspaces and distinguishes closing Herdr state from deleting a checkout. [Configuration](https://herdr.dev/docs/configuration/#worktrees) · [CLI reference](https://herdr.dev/docs/cli-reference/#worktrees) |
| Scrollback workflow | `edit_scrollback` is disabled because `prefix+e` opens ranger; `prefix+u` lost `tmux-open`. | Bind `edit_scrollback = "prefix+u"`. | It opens focused-pane scrollback in `$EDITOR`, a useful native replacement for reviewing/copying output even though it is not an fzf URL/file picker. [Config reference](https://herdr.dev/docs/config-reference/) |
| Agent awareness + restore | Agent commands exist, but `herdr integration status` shows Claude, Codex, and Pi integrations absent. | Install the integrations for the agents actually used: `herdr integration install claude`, `herdr integration install codex`, `herdr integration install pi`; keep `[session] resume_agents_on_restore = true` (the default). | Official hooks report native session IDs, allowing Herdr to restore supported agent conversations after a server restart; ordinary shells cannot do this. [Integrations](https://herdr.dev/docs/integrations/) · [Session state](https://herdr.dev/docs/session-state/#native-agent-session-restore) |
| Agent sidebar | Defaults leave pane borders anonymous and agents ordered by workspace. | Add `show_agent_labels_on_pane_borders = true` and `agent_panel_sort = "priority"`. | The sidebar is a cross-workspace agent dashboard; priority ordering puts blocked/done work first. [Configuration](https://herdr.dev/docs/configuration/#ui-and-sidebar) |
| Background attention | Current port disables both toast and sound to mimic tmux's quiet activity behavior. | Enable desktop notifications, but keep sound muted: `[ui.toast] delivery = "system"; delay_seconds = 10`; retain `[ui.sound] enabled = false`. Bind `open_notification_target = "prefix+o"` if it is not already default. | Herdr suppresses active-tab notifications, delays only while the state persists, and on macOS uses terminal-notifier or osascript. This is agent attention routing, not tmux visual activity/bells. [Configuration](https://herdr.dev/docs/configuration/#notifications) |
| Remote-first Mac workflow | `remote_image_paste` is explicitly disabled. | Delete that override so its default `ctrl+v` applies during `herdr --remote`; keep `[remote] manage_ssh_config = true` (the default). | Local Herdr can attach to Linux/macOS x86_64/aarch64 servers, retain local keybindings, use a managed SSH control socket/keepalives, and bridge local clipboard images. Custom local command bindings intentionally do not transfer to the remote host. [Persistence and remote access](https://herdr.dev/docs/persistence-remote/#remote-attach-over-ssh) |

## Optional later

| Capability | Proposal | Reason / source |
| --- | --- | --- |
| Automatic theme switching and token tuning | Keep `name = "rose-pine"`; only add `auto_switch`, `dark_name`, `light_name`, or `[theme.custom]` after testing terminal appearance. | Herdr supports Rose Pine, host light/dark switching, and color-token overrides; the current tmux Rose Pine choice is already faithfully retained. [Configuration](https://herdr.dev/docs/configuration/#theme) · [Config reference](https://herdr.dev/docs/config-reference/) |
| Sidebar/mouse polish | Consider `sidebar_collapsed_mode = "compact"`, `mouse_scroll_lines = 5`, and `right_click_passthrough_modifier = "ctrl"`. Keep capture enabled unless terminal-native Cmd-click is more important. | Ctrl-click opens links while captured; macOS terminal-native bypass is Shift-Cmd-click. Right-click passthrough lets TUI apps receive the modified gesture. [Configuration](https://herdr.dev/docs/configuration/#ui-and-sidebar) |
| Longer restart review | Set `[experimental] pane_history = true` only after accepting that `session-history.json` can contain prompts, tokens, and output. | Layout/cwd/focus restore is already native; pane-history replay is deliberately opt-in because of stored sensitive terminal content. [Session state](https://herdr.dev/docs/session-state/#pane-screen-history-replay) |
| Sound | Leave global sound off, or enable only selected agents with `[ui.sound.agents] claude = "on"; codex = "on"`. | Sounds are local-client playback (`afplay` on macOS) and can be scoped per detected agent. [Configuration](https://herdr.dev/docs/configuration/#sound) |
| Scripted workflow plugins | Use the existing Sessionizer for project discovery; build/link a small trusted local plugin only when an exact workflow needs layouts, post-worktree setup, overlay panes, or link routing. | Plugins can declare actions, `worktree.created` events, overlay/split/tab/zoomed panes, and modified-link handlers; they are ordinary unsandboxed local code, so review and pin third-party sources. [Plugins](https://herdr.dev/docs/plugins/) · [Marketplace](https://herdr.dev/docs/marketplace/) |
| Direct agent/pane navigation | Add `focus_agent = "prefix+alt+1..9"` only if the terminal transmits those chords reliably. | Indexed agent focus exists, but macOS terminal input can alter Alt/Option chords; test before depending on it. [Configuration](https://herdr.dev/docs/configuration/#indexed-jumps) · [Keyboard](https://herdr.dev/docs/keyboard/#going-prefix-free) |

## Deliberately decline / not available

| Item | Classification | Reason / source |
| --- | --- | --- |
| Popup promotion and a programmable tmux status line | Not available as a native equivalent. | A simple `type = "pane"` command is temporary and closes on process exit. Use a plugin pane for an overlay/split/tab/zoomed temporary tool; plugins still do not provide a native non-terminal UI, and Herdr's sidebar replaces rather than exposes tmux status-format programming. [Custom commands](https://herdr.dev/docs/configuration/#custom-command-keybindings) · [Plugins](https://herdr.dev/docs/plugins/#panes) |
| Full process survival after a server stop | Not available; use detach/reattach instead. | Detach keeps all processes alive. A full restart restores shape/cwd/layout/focus, then restarts eligible agent conversations or fresh shells; experimental handoff is best-effort. [Session state](https://herdr.dev/docs/session-state/) |
| `pane_history`, nested Herdr, Kitty graphics | Deliberately decline for now. | History stores potentially sensitive output; nested launches and Kitty graphics are explicitly experimental/testing options. [Configuration](https://herdr.dev/docs/configuration/#pane-screen-history) |
| CJK input options | Deliberately decline unless a CJK IME is used. | macOS-only ASCII prefix switching and hidden-cursor tracking solve IME-specific agent-TUI issues, with an extra visible cursor trade-off. [Configuration](https://herdr.dev/docs/configuration/#ime-cursor-tracking) |

## Exact config delta to discuss before editing

```toml
[keys]
goto = "prefix+f"
workspace_picker = "prefix+shift+f"
previous_workspace = "prefix+shift+left"
next_workspace = "prefix+shift+right"
switch_workspace = "prefix+shift+1..9"
new_worktree = "prefix+shift+g"
open_worktree = "prefix+shift+o"
edit_scrollback = "prefix+u"
remote_image_paste = "ctrl+v"
open_notification_target = "prefix+o"

[ui]
show_agent_labels_on_pane_borders = true
agent_panel_sort = "priority"

[ui.toast]
delivery = "system"
delay_seconds = 10

[session]
resume_agents_on_restore = true
```

This deliberately replaces the Sessionizer worktree binding at `prefix+shift+g` with Herdr's native, current-workspace-aware worktree flow, while leaving its project picker at `prefix+ctrl+s`. Remove the existing empty overrides for the proposed native actions rather than leaving competing values in the file. Custom command bindings already receive active workspace/tab/pane/cwd context, so a later `tmux-open` replacement can be a small shell command or a local plugin rather than another tmux dependency. [Configuration](https://herdr.dev/docs/configuration/#custom-command-keybindings)
