# macOS Sway Parity Plan

This plan tracks the remaining work to make the macOS AeroSpace/Alfred setup feel like the Linux Sway workflow without stealing important native macOS shortcuts.

## Current Direction

- AeroSpace owns deterministic tiling, focus, movement, and workspaces.
- Alfred owns fuzzy command-palette workflows: launcher, window picker, clipboard, notes, snippets, and scripted dispatch.
- Native macOS `cmd-*` app shortcuts should generally pass through.
- AeroSpace WM bindings use `cmd-alt-*` for high-frequency actions, with `cmd-ctrl-a` and `cmd-ctrl-;` as mode-entry exceptions.
- Lower-frequency actions belong in service/app modes.

## Implemented

| Area | State |
|---|---|
| Core AeroSpace WM layer | `cmd-alt-h/j/k/l`, `cmd-alt-1..0`, `cmd-alt-shift-1..0` |
| Native macOS shortcut restoration | `cmd-c/v/a/f/h/l/tab/1..0` pass through; screenshots are in AeroSpace service mode |
| App launcher mode | `cmd-ctrl-a`, then `q`, `shift-q`, `shift-n`, `e`, `b`, `m`, `n` |
| Shared app focus/launch helper | `bin/aerospace-focus-or-launch` backs AeroSpace app mode and future Alfred actions |
| Alfred window picker | `cmd-ctrl-p` or `aw` launches the symlinked Alfred workflow; `cmd-tab` remains a macOS-reserved app switcher shortcut |
| Alfred clipboard picker | Use Alfred's native Clipboard History viewer |
| Scratch notes | AeroSpace service mode `s` toggles `~/scratch.md`; `shift-s` opens an ephemeral nvim note |
| Sway app launcher mode | `$mod+Alt+a` mirrors the macOS app mode letters |
| Sway kill alignment | `$mod+q` kills focused window; terminal moved to app mode `q` |
| Lock alignment | Sway also binds `$mod+Ctrl+q` for lock |
| General scratchpad | Deferred; AeroSpace helper behavior did not match Sway closely enough |
| Fullscreen alignment | `cmd-alt-f` toggles AeroSpace fullscreen |
| Swap alignment | `cmd-alt-ctrl-h/j/k/l` swaps windows |
| Media direction | Use native media keys on macOS |

## Phase 1: Alfred Window Control

Goal: replace Sway `$mod+p` with a fuzzy AeroSpace window switcher.

| Task | Shape |
|---|---|
| Window switcher | Done: symlinked Alfred workflow uses `cmd-ctrl-p` and keyword `aw`; action runs `aerospace focus --window-id <id>`. |
| Current-workspace switcher | Not planned for now; one picker covers all AeroSpace windows. |
| Workspace overview | Alfred lists workspaces and visible windows; actions focus workspace or selected window. |
| Keybinding decision | Avoid bare `cmd-p` unless explicitly accepting Print conflict. Prefer Alfred keyword first, then choose hotkey. |

## Phase 2: Shared App Focus/Launch

Goal: stop duplicating app-launch behavior between AeroSpace and Alfred.

| Task | Shape |
|---|---|
| Shared helper | Done: `bin/aerospace-focus-or-launch` focuses an existing app window or runs `open -a <App>`. |
| AeroSpace app mode | Done: app mode calls the helper. |
| Alfred app workflows | Reuse the helper for fuzzy app actions. |

## Phase 3: Scratch Notes

Goal: port the dedicated Sway scratch note workflows.

| Workflow | macOS target |
|---|---|
| Persistent scratch note | Done: service mode `s` toggles a named Ghostty window running `nvim ~/scratch.md`. |
| Ephemeral scratch note | Done: service mode `shift-s` opens a throwaway Ghostty/nvim buffer. |

Constraints:

- Do not use bare `cmd-s`; Save should remain native.
- Keep scratch note separate from the general window scratchpad.
- Prefer Ghostty/nvim to keep the workflow close to Linux.

## Phase 4: AeroSpace Scratchpad

Goal: approximate Sway’s general scratchpad for arbitrary windows.

| Task | Shape |
|---|---|
| Research helper | Deferred; no active helper. |
| Show/hide | Deferred; no active AeroSpace binding. |
| Move-to-scratchpad | Deferred; no active AeroSpace binding. |

Constraint: AeroSpace has no native Sway scratchpad, so this will be an approximation.

## Phase 5: Clipboard

Goal: replace Sway `cliphist` muscle memory with a macOS-native picker.

| Option | Direction |
|---|---|
| Alfred Clipboard History | Use Alfred's native Clipboard History viewer and configured viewer hotkey. |
| Maccy | Fallback if Alfred clipboard is unavailable or insufficient. |
| Raycast | Not preferred unless switching launcher stack. |

Prefer Alfred's native Clipboard History UI over maintaining a custom workflow around Alfred's internal clipboard database.

## Phase 6: Power/System Commands

Goal: provide a Sway-like power menu where useful.

Candidate actions:

- Lock screen
- Sleep
- Restart
- Shut down
- Log out

Likely implementation: Alfred workflow or small script using macOS system commands. Expect macOS confirmation dialogs and permission quirks.

## Phase 7: Dictation

Goal: decide whether to port Sway dictation.

Options:

- Native macOS dictation
- Wispr Flow
- Custom script equivalent to the Linux Handy/Ollama/wtype flow

No implementation until the desired macOS dictation backend is clear.

## Phase 8: Sway Keymap Convergence

Goal: make Linux and macOS mental models converge further.

Open issue: AeroSpace now uses `cmd-alt-h/j/k/l` for focus, but Sway uses bare `$mod+h/j/k/l`.

Likely path:

1. Move Sway resize into an explicit `resize` mode.
2. Decide whether Sway should gain `$mod+Alt+h/j/k/l` focus aliases for physical parity with macOS.
3. Decide whether Sway should gain `$mod+Alt+Shift+h/j/k/l` move aliases for physical parity with macOS.
4. Decide whether to keep old bare `$mod+h/j/k/l` bindings as aliases.

## Cleanup Decisions

| Item | Decision needed |
|---|---|
| AeroSpace service mode | Done: `cmd-ctrl-semicolon` avoids the native spelling/grammar shortcut. |
| `cmd-enter` terminal | Done: no AeroSpace binding; app mode `q` is the terminal path and opens Ghostty. |
| AeroSpace swap bindings | Done: swap moved to `cmd-alt-ctrl-h/j/k/l` so `cmd-alt-h/j/k/l` can focus. |
| App mode cancel | Done: app mode accepts both `esc` and `enter`, matching Sway's `Escape`/`Return` exits. |
| Resize step | Done: AeroSpace resize bindings use Sway's `10 px` step on `cmd-alt-ctrl` arrows. |
| Workspace next/prev | Done: `cmd-alt-[` / `cmd-alt-]` cycle workspaces on the focused monitor. |
| Screenshot workflow | Done: service mode `3/4/5` captures screen, area/window, or opens Screenshot; `shift-3/shift-4` copy to clipboard. Use Screenshot UI for recording. |

## Proposed Build Order

1. Alfred window switcher.
2. Shared app focus/launch helper.
3. Scratch note workflows.
4. Clipboard via Alfred.
5. Power/system command workflow.
6. Sway resize-mode migration for deeper keymap convergence.
