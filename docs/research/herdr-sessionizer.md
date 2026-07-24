# Herdr equivalent to `tmux-sessionizer`

## Conclusion

Yes. [`andrewchng/herdr-sessionizer`](https://github.com/andrewchng/herdr-sessionizer) is a purpose-built, community Herdr plugin explicitly inspired by ThePrimeagen's `tmux-sessionizer`. It is the closest direct replacement for this repository's [`bin/tmux-sessionizer`](/Users/jonco/src/dotfiles/bin/tmux-sessionizer): it fuzzy-picks existing Herdr workspaces first, then project directories; opening a project creates a Herdr workspace at that directory and bootstraps a configurable tab/pane/command layout.

It is not a built-in Herdr command and it is not an official Herdr-maintained plugin. It is, however, discoverable through Herdr's official plugin mechanism: the official plugin documentation says the marketplace indexes public GitHub repositories tagged `herdr-plugin`, and this repository has that topic. [Herdr plugin documentation](https://herdr.dev/docs/plugins/) · [plugin repository metadata](https://github.com/andrewchng/herdr-sessionizer)

As inspected on 2026-07-14, the plugin declares `min_herdr_version = "0.7.0"`, `platforms = ["macos"]`, and uses Bun plus `fzf`; therefore it cannot be the current EndeavourOS replacement without either upstream Linux support or a small maintained fork. [Manifest](https://github.com/andrewchng/herdr-sessionizer/blob/main/herdr-plugin.toml) · [README requirements](https://github.com/andrewchng/herdr-sessionizer#requirements)

## Workflow comparison

| Current `tmux-sessionizer` behavior | Herdr Sessionizer equivalent | Parity |
| --- | --- | --- |
| Shows current tmux sessions and project directories in one `fzf` picker. | `sessionizer.open` first shows existing Herdr workspaces; pressing Esc then opens its project picker. | Equivalent two-stage flow; it lists workspaces, not named Herdr sessions. |
| Searches configurable roots, optional extra roots/depths, and explicit paths. | `[projects].roots`, `git_only`, and `depth` configure discovery; roots also accept `*`/`**` globs. | Near-equivalent; no documented hard-coded individual-path field, but an individual directory can be made a root. |
| Creates/attaches a tmux session whose working directory is the selected project. | Creates a Herdr workspace with `--cwd <project>` and focuses it. | Equivalent at the project-workspace level. |
| Optionally sources project/global `.tmux-sessionizer` after creation. | Applies a global layout or `<project>/.sessionizer/config.toml` only when it creates a workspace. Layouts create tabs, splits, and commands. | Stronger declarative replacement, but no shell-source hook. |
| `TS_SESSION_COMMANDS` opens indexed tmux windows or cached split panes, re-focusing existing panes. | Layout panes can run declared commands; Herdr itself supports `workspace`, `tab`, and `pane` CLI operations. | Bootstrap is covered; no documented indexed command slots or persistent-pane cache. |

The current script's details are in [`bin/tmux-sessionizer`](/Users/jonco/src/dotfiles/bin/tmux-sessionizer): it treats selected project basenames as session names, passes the project as tmux's `-c` directory, and reserves windows `69+` or cached split panes for `TS_SESSION_COMMANDS`.

## Recommended use

Install and bind the plugin after its platform declaration supports this machine:

```sh
herdr plugin install andrewchng/herdr-sessionizer --yes
herdr plugin config-dir sessionizer
```

```toml
[[keys.command]]
key = "prefix+f"
type = "plugin_action"
command = "sessionizer.open"
description = "open project workspace"

[[keys.command]]
key = "prefix+up"
type = "plugin_action"
command = "sessionizer.worktree-open"
description = "open worktree workspace"
```

Those are the plugin author's documented installation and binding patterns. [README setup and usage](https://github.com/andrewchng/herdr-sessionizer#setup) · [manifest actions](https://github.com/andrewchng/herdr-sessionizer/blob/main/herdr-plugin.toml)

For this dotfiles layout, configure roots corresponding to the current sessionizer search locations and make the new-workspace layout launch the wanted persistent tools. Example shape:

```toml
[projects]
roots = ["~/src", "~/.config"]
git_only = true
depth = 3

[layout]
placement = "overlay"
focus = "shell"

[tabs.dev]
label = "dev"

[[tabs.dev.panes]]
id = "shell"
title = "shell"
command = "zsh"
```

Herdr's native CLI supplies the primitives underneath this pattern: `workspace create --cwd`, `workspace focus`, `tab create --cwd`, and `pane split --cwd`; new panes/tabs/workspaces can also inherit the source working directory through `[terminal].new_cwd = "follow"`. [CLI reference](https://herdr.dev/docs/cli-reference/) · [configuration](https://herdr.dev/docs/configuration/)

## Useful additions over tmux

- `sessionizer.worktree-open` can reopen an existing worktree workspace or create a worktree from local/remote branches; the tmux script has no Git-worktree flow. [README worktree flow](https://github.com/andrewchng/herdr-sessionizer#usage)
- Existing workspaces are focused without reapplying layout, while newly created project/worktree workspaces receive the global or repo-local layout. This avoids destroying in-progress layouts. [README layout configuration](https://github.com/andrewchng/herdr-sessionizer#layout-configuration) · [implementation](https://github.com/andrewchng/herdr-sessionizer/blob/main/src/sessionizer/sessionizer.ts)
- Per-repository `.sessionizer/config.toml` can replace the creation layout, letting this repo launch a different tab/pane arrangement than other projects. [README per-repo overrides](https://github.com/andrewchng/herdr-sessionizer#per-repo-layout-overrides)

## Gaps and alternatives

- The plugin's current macOS-only manifest is the immediate blocker for this EndeavourOS setup. Its README says Linux support is planned; the manifest is authoritative for installation compatibility. [README](https://github.com/andrewchng/herdr-sessionizer#sessionizer) · [manifest](https://github.com/andrewchng/herdr-sessionizer/blob/main/herdr-plugin.toml)
- It switches **Herdr workspaces**, not named Herdr sessions. That is usually the correct tmux-sessionizer mapping: Herdr documents named sessions as separate server namespaces and recommends workspaces first for project-level organization. [Herdr concepts](https://herdr.dev/docs/concepts/)
- There is no direct replacement for the script's `TS_SESSION_COMMANDS` index-to-window/pane cache. Use the plugin's creation layout for durable per-project tools; use Herdr custom commands or plugin actions for ad hoc tools. Custom `type = "pane"` commands are temporary panes that close when the command exits. [Herdr configuration](https://herdr.dev/docs/configuration/)
- If platform support is needed immediately, a small Linux fork is straightforward in shape but should be treated as new work: change the manifest platform list only after testing the Bun/fzf/Herdr CLI workflow on Linux. Herdr plugins are explicitly ordinary executable packages that can invoke the full Herdr CLI, so this is a supported extension path rather than a private API workaround. [Herdr plugins](https://herdr.dev/docs/plugins/)
