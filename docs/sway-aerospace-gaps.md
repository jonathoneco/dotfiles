# Sway vs AeroSpace Gaps

Core focus, move, workspace, and app-launch mental models are now close. The remaining gaps are mostly non-core workflows, macOS shortcut conflicts, and places where Sway has compositor-native behavior that AeroSpace can only approximate.

## Still Missing In AeroSpace

| Sway binding | Sway action | AeroSpace status |
|---|---|---|
| `$mod+q` | Kill focused window | Unbound to preserve native `cmd-q` quit |
| `$mod+space` | Launcher | Unbound so Alfred can own `cmd-space` |
| `$mod+a` | Focus parent | Unbound to preserve `cmd-a` select all |
| `$mod+p` | Custom window switcher | Not ported |
| `$mod+Shift+e` | Power menu | Not ported; native lock chord is aligned |
| `$mod+Shift+p` | TLP profile menu | Linux-only |
| `$mod+Shift+o` | Display layout editor | Not ported |
| `$mod+f1` | Lock screen | Native `cmd-ctrl-q`; Sway also binds `$mod+Ctrl+q` |
| `$mod+s` | Persistent scratch note | Service mode `s` |
| `$mod+Shift+s` | Ephemeral scratch note | Service mode `Shift+s` |
| `$mod+minus` / `$mod+Shift+minus` | Sway scratchpad show/move | Deferred |
| `$mod+Ctrl+;` | Media play/pause | Not ported |
| `$mod+Ctrl+n/p` | Media next/previous | Not ported |
| `$mod+Ctrl+v/x` | Clipboard picker/delete | Not ported |
| `$mod+v` / `$mod+Shift+v` | Dictation | Wispr Flow handles macOS dictation |
| `Print`, `Ctrl+Print`, `Shift+Print` | Screenshots | Service mode `3/4/5` and `Shift+3/4` |
| `$mod+Print`, `$mod+Shift+Print` | Screen recording | Use Screenshot UI via service mode `5` |
| `$mod+button4/5` | Pointer resize | Not ported |

## Annotation Notes

### Keymap Direction After macOS Conflicts

The native `cmd-*` layer is too valuable to treat as a universal WM layer. The current implemented direction is:

- Keep native macOS `cmd-c/v/x/z/a/f/h/l/tab/number` behavior where it matters.
- Keep app launching behind app mode.
- Move high-conflict AeroSpace bindings away from bare `cmd-*`.
- Use service modes for lower-frequency actions.
- Use `cmd-alt-*` as the AeroSpace WM layer for high-frequency focus and workspace switching.
- Use `cmd-alt-shift-<number>` for the semantic "move focused window to workspace" layer.
- Keep `cmd-ctrl-a` and `cmd-ctrl-;` as mode-entry exceptions.

Candidate AeroSpace migration:

| Previous AeroSpace binding | Problem | Current replacement |
|---|---|---|
| `cmd-f` fullscreen | Blocks Find | `cmd-alt-f` |
| `$mod+f` fullscreen | Preserve Sway muscle memory without blocking Find | `cmd-alt-f` |
| `cmd-h/j/k/l` focus | `cmd-h` hides, `cmd-l` address bar | `cmd-alt-h/j/k/l` |
| `cmd-shift-h/j/k/l` move | Inherits focus conflicts | `cmd-alt-shift-h/j/k/l` |
| `cmd-tab` / `cmd-shift-tab` workspace prev/next | Blocks macOS app switcher | `cmd-alt-[` / `cmd-alt-]` |
| `cmd-arrow` focus | Blocks text navigation | Dropped; use vim-style bindings |
| `cmd-shift-arrow` move | Blocks text selection | Dropped; use vim-style bindings |
| `cmd-1..0` workspaces | Blocks browser tab selection/Finder views | `cmd-alt-1..0` |
| `cmd-shift-1..0` move to workspace | Blocks screenshots on 3/4/5 | `cmd-alt-shift-1..0`; screenshots move into service mode |
| `cmd-ctrl-space` focus floating/DFS next | Blocks emoji picker | service mode `space` |
| `cmd-shift-semicolon` service mode | Blocks spelling and grammar | `cmd-ctrl-semicolon` |

Sway has not fully moved to `$mod+Ctrl-*` because `$mod+Ctrl+h/j/k/l` is currently resize there. Converging Sway fully requires moving resize into a mode first.

### Kill

Sway now uses `$mod+q` for kill. Terminal launch moved fully into app mode: `$mod+Alt+a`, then `q`. AeroSpace leaves `cmd-q` unbound so native macOS Quit keeps working.

### Focus Parent

Sway `$mod+a` maps to `focus parent`. AeroSpace does not expose a direct `focus parent` equivalent in the current command set; its docs explicitly say `focus child|parent` is not supported. The closest available layout/tree commands are:

- `join-with <direction>`: group the focused window with a neighbor.
- `flatten-workspace-tree`: collapse unnecessary nesting.
- `focus <direction>` / `focus dfs-next` / `focus dfs-prev`: move focus through the tree, but not specifically to a parent container.

Practical binding choice: keep `cmd-a` unbound for Select All, and use service mode for tree operations.

### Power Menu

The macOS native equivalents are fragmented rather than one built-in menu:

- Lock screen: `Control+Command+Q`.
- Sleep/restart/shut down/log out: Apple menu items and confirmation dialogs.
- Automation path: a small script using `osascript`/`pmset`/`open` can provide a Sway-like chooser, but it will not be as compositor-native as the Linux power menu.

Sway now also binds `$mod+Ctrl+q` to lock, matching the macOS physical chord when `$mod` is Command/Super.

### Window Switcher

macOS `cmd-tab` is app-switching, visual, and not fuzzy. A closer match to the Sway `swaymsg + fuzzel` switcher would be one of:

- Alfred workflow that queries `aerospace list-windows` and focuses the selected window.
- Script using `aerospace list-windows --json`, `jq`, and a picker.
- Dedicated app switcher like AltTab, though that is still more visual than fuzzy.

Best fit for the existing mental model: make `$mod+p` / `cmd+p` invoke a fuzzy Aerospace window picker once Alfred or another picker is settled.

### Alfred Workflow Direction

Alfred should be the fuzzy command palette layer, not the tiler. Let AeroSpace own deterministic layout/workspaces; let Alfred own fuzzy selection, clipboard, snippets, notes, and scripted dispatch.

Good first workflow targets:

| Workflow | Feasibility | Shape |
|---|---:|---|
| Window switcher | High | Script Filter calls `aerospace list-windows --all --json`, displays rows, then runs `aerospace focus --window-id <id>`. |
| Current-workspace switcher | High | Same as window switcher, filtered to the focused workspace. |
| Workspace overview | High | Script Filter lists workspaces/windows and runs `aerospace workspace <name>` or move commands. |
| Focus-or-launch app | High | Shared helper checks existing AeroSpace windows for app, focuses one if present, otherwise `open -a <App>`. |
| Clipboard picker | High | Use Alfred's native Clipboard History if Powerpack is available; do not recreate it in scripts. |
| Scratch note | High | Plain markdown append/open workflow is the simplest dotfiles-friendly starting point. |
| System commands | Medium-high | Alfred can run lock/sleep/restart scripts, but macOS dialogs and permissions make this less native than Sway. |
| Dev tools | High | Thin workflows around `gh`, `git`, `mise`, `rg`, `fd`, docs, and repo openers are a good fit. |

Implementation notes:

- Alfred Script Filters should emit JSON.
- Alfred scripts need explicit PATH setup for Homebrew, AeroSpace, and mise tools.
- Prefer Alfred native file search, snippets, and clipboard before custom scripts.
- Avoid AppleScript-heavy core navigation; use AeroSpace CLI where possible.
- Keep Alfred on `cmd-space`; do not bind AeroSpace over it.

### Scratch Notes And Scratchpad

AeroSpace does not have a native Sway scratchpad. There are community scripts that approximate this by moving windows to a hidden scratchpad workspace and showing them later as floating windows. A macOS scratch note could be implemented as:

- a named Ghostty window running `nvim ~/scratch.md`;
- an AeroSpace/Hammerspoon/script toggle that detects the window, shows/hides it, and floats/centers it;
- separate bindings for persistent and ephemeral scratch notes.

Because `cmd-s` is Save, scratch note bindings should not use bare `cmd-s`. Candidate trigger: service mode or `cmd-alt-s`.

Target model:

| Workflow | Sway today | macOS target |
|---|---|---|
| Persistent scratch note | `$mod+s` | service mode `s` opens/toggles Ghostty scratch note |
| Ephemeral scratch note | `$mod+Shift+s` | service mode `Shift+s` opens throwaway Ghostty/nvim buffer |
| Window scratchpad | `$mod+minus` / `$mod+Shift+minus` | Deferred; no active AeroSpace binding |

Keep the dedicated scratch note separate from the general window scratchpad.

### Clipboard Picker

macOS options:

- Alfred Clipboard History if Alfred Powerpack is available.
- Maccy for a small native clipboard manager.
- Raycast Clipboard History if using Raycast.

Given the interest in using Alfred more, Alfred Clipboard History is the first thing to evaluate before adding another daemon.

### Media Controls

Media bindings can be ported. Options:

- Prefer native media keys if Kanata already emits them on the function row.

Decision: use native media keys on macOS rather than app-specific AppleScript or an extra Now Playing helper.

### Native macOS Shortcut Audit

Apple documents that apps can define their own shortcuts, so this list is a starting point, not an exhaustive guarantee. These are the macOS-native bindings most relevant to the current AeroSpace config.

| Shortcut | Native macOS behavior | Current Sway use | Current AeroSpace use | Decision |
|---|---|---|---|---|
| `cmd-c` | Copy | `$mod+c` is unbound; kill moved to `$mod+q` | Unbound | Keep native |
| `cmd-v` | Paste | `$mod+v` dictation | Unbound | Keep native |
| `cmd-x` | Cut | No bare `$mod+x`; `$mod+Ctrl+x` deletes cliphist entry | Unbound | Keep native |
| `cmd-z` | Undo | No `$mod+z` binding | Unbound | Keep native |
| `cmd-a` | Select all | `$mod+a` focus parent | Unbound | Keep native |
| `cmd-f` | Find | `$mod+f` fullscreen | Unbound; fullscreen is `cmd-alt-f` | Keep native |
| `cmd-h` | Hide front app | `$mod+h` focus left | Unbound; focus left is `cmd-alt-h` | Keep native |
| `cmd-l` | Browser location bar / app-specific | `$mod+l` focus right | Unbound; focus right is `cmd-alt-l` | Keep native |
| `cmd-m` | Minimize front window | App mode `m` opens mail | Unbound | Keep native |
| `cmd-n` | New window/document | App mode `n` opens Notion | Unbound | Keep native |
| `cmd-o` | Open | No `$mod+o` binding | Unbound | Keep native |
| `cmd-p` | Print | `$mod+p` window switcher | Not currently bound | Candidate fuzzy window switcher, but conflict is real |
| `cmd-q` | Quit app | `$mod+q` kill focused window | Unbound | Keep native |
| `cmd-s` | Save | `$mod+s` persistent scratch note | Unbound | Keep native |
| `cmd-t` | New tab | No `$mod+t` binding | Unbound | Keep native |
| `cmd-w` | Close front window | No active `$mod+w` binding | Unbound | Keep native |
| `cmd-space` | Spotlight / launcher | `$mod+space` launcher | Unbound | Alfred should own this outside AeroSpace |
| `cmd-tab` | App switcher | `$mod+Tab` next workspace on output | Unbound; workspace next is `cmd-alt-]` | Keep native |
| `cmd-shift-tab` | Reverse app switcher / app-specific | `$mod+Shift+Tab` previous workspace on output | Unbound; workspace previous is `cmd-alt-[` | Keep native |
| `cmd-ctrl-space` | Character Viewer / emoji picker | `$mod+Ctrl+space` focus mode toggle | Unbound; floating/DFS next in service mode | Keep native |
| `cmd-left/right` | Text line start/end; Finder navigation variants | `$mod+Left/Right` focus | Unbound | Keep native |
| `cmd-up/down` | Text document start/end; Finder enclosing/open item | `$mod+Up/Down` focus | Unbound | Keep native |
| `cmd-shift-left/right/up/down` | Select text to line/document boundaries | `$mod+Shift+arrow` move window | Unbound | Keep native |
| `cmd-1..4` | Finder views; browser tab selection | `$mod+1..4` workspaces | Unbound; workspaces are `cmd-alt-1..4` | Keep native |
| `cmd-5..9` | Browser tab selection / app-specific | `$mod+5..9` workspaces | Unbound; workspaces are `cmd-alt-5..9` | Keep native |
| `cmd-0` | Actual size/default zoom / app-specific | `$mod+0` workspace 10 | Unbound; workspace 10 is `cmd-alt-0` | Keep native |
| `cmd-shift-3` | Screenshot entire screen | `$mod+Shift+3` move focused window to workspace 3 | Unbound; move to workspace is `cmd-alt-shift-3` | Service mode screenshots |
| `cmd-shift-4` | Screenshot selected area | `$mod+Shift+4` move focused window to workspace 4 | Unbound; move to workspace is `cmd-alt-shift-4` | Service mode screenshots |
| `cmd-shift-5` | Screenshot/recording UI | `$mod+Shift+5` move focused window to workspace 5 | Unbound; move to workspace is `cmd-alt-shift-5` | Service mode screenshots |
| `cmd-shift-q` | Log out prompt | App mode `Shift+q` opens Cursor | Unbound | Keep native |
| `cmd-shift-n` | New folder in Finder / app-specific | App mode `Shift+n` opens Linear | Unbound | Keep native |
| `cmd-shift-semicolon` / `cmd-:` | Spelling and grammar | No equivalent binding | Unbound; service mode is `cmd-ctrl-semicolon` | Keep native |
| `option-cmd-space` | Finder search window | No equivalent binding | Unbound | Keep native |

### Screenshots And Recording

macOS owns these important screenshot shortcuts:

| Shortcut | Native macOS behavior |
|---|---|
| `cmd-shift-3` | Capture the entire screen |
| `cmd-shift-4` | Capture a selected area |
| `cmd-shift-4`, then `space` | Capture a window or menu |
| `cmd-shift-5` | Open the Screenshot app for screenshot and recording options |

These conflicted with the more semantic AeroSpace workspace movement layer. Screenshots now live behind AeroSpace service mode:

| Screenshot action | AeroSpace shortcut |
|---|---|
| Save entire screen | `cmd-alt-;`, then `3` |
| Copy entire screen | `cmd-alt-;`, then `Shift+3` |
| Save selected area / window via `space` | `cmd-alt-;`, then `4` |
| Copy selected area / window via `space` | `cmd-alt-;`, then `Shift+4` |
| Screenshot and recording options | `cmd-alt-;`, then `5` |

AeroSpace keeps `cmd-alt-<number>` for switching workspace, and `cmd-alt-shift-<number>` moves the focused window to that workspace.

## Sources

- Apple Mac keyboard shortcuts: https://support.apple.com/en-us/102650
- AeroSpace commands: https://nikitabobko.github.io/AeroSpace/commands
- AeroSpace guide: https://nikitabobko.github.io/AeroSpace/guide
- AeroSpace scratchpad feature request: https://github.com/nikitabobko/AeroSpace/issues/272
- Alfred workflows: https://www.alfredapp.com/help/workflows/
- Alfred Script Filter: https://www.alfredapp.com/help/workflows/inputs/script-filter/
- Alfred Clipboard History: https://www.alfredapp.com/help/features/clipboard/
- Alfred AeroSpace workflow example: https://www.alfredforum.com/topic/23653-aerospace-%E2%80%94-alfred-workflow-for-shortcuts-window-switching-and-workspace-overview/
- AeroSpace Alfred workflow example: https://github.com/yuriteixeira/aerospace-workflow

## Behavioral Differences

| Area | Difference |
|---|---|
| Terminal launch | Sway app mode `q` uses `$term`; AeroSpace app mode `q` uses Ghostty. No active `cmd-enter` terminal binding. |
| App mode cancel | Sway and AeroSpace app modes both support `Escape` and `Return`/`Enter`. |
| Resize step | Sway and AeroSpace resize bindings use `10 px`. |
| Floating focus toggle | Sway `$mod+ctrl+space` is `focus mode_toggle`; AeroSpace uses `focus --ignore-floating dfs-next`. |
| Fullscreen | Sway fullscreen is compositor-native; AeroSpace fullscreen is AeroSpace-managed macOS window behavior. Fast path is `cmd-alt-f`. |
| Scratchpad | Sway has native scratchpad; AeroSpace has no active equivalent in this config. |
| Workspace next/prev | Sway uses `next_on_output` / `prev_on_output`; AeroSpace uses `aerospace-workspace-cycle` to cycle workspaces on the focused monitor. |
| Display movement | Sway outputs are compositor-controlled; AeroSpace monitor behavior is constrained by macOS. |

## Highest-Value Next Ports

1. Window switcher (`$mod+p`)
2. Scratch note (`$mod+s`)
3. Power menu (`$mod+Shift+e`)
4. Dictation refinements if Wispr Flow stops being enough

## Cleanup Candidates

- Use the native Screenshot launcher for recording rather than maintaining separate recording bindings.
