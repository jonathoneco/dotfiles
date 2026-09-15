# Herdr copy mode and richer visual selection

Research date: 2026-07-26. The live binary inspected was `herdr 0.7.3`; current
upstream stable is v0.7.5.

## Conclusion

There is no Herdr 0.7.3 configuration that turns native copy mode into tmux's
full Vi copy table. The config can change only the key used to *enter* copy
mode. Once inside, every motion and selection key is hard-coded. Native mode is
useful for quick characterwise or linewise yanks, but it is intentionally a
small Vi-like subset rather than a configurable Vim implementation.

The best low-disruption fit for this dotfiles setup is to keep quick native
copy mode on `prefix+v` and bind Herdr's retained-scrollback Neovim view to a
free chord such as `prefix+shift+v`. That adds real Vim motions, text objects,
search, visual block, marks, and the rest of the installed Neovim
configuration without changing existing muscle memory or adding a custom
capture script:

```toml
[keys]
copy_mode = "prefix+v"
edit_scrollback = "prefix+shift+v"
```

The upstream default `prefix+e` cannot be restored unchanged because this
config already assigns it to ranger at
`/Users/jonco/src/dotfiles/config/herdr/config.toml:169`.
If the requirement is specifically that `prefix+v` itself always provide the
rich path, an equally valid alternative is to move native copy mode back to
`prefix+[` and put `edit_scrollback` on `prefix+v`.

This is especially low-friction here because the environment already exports
`EDITOR=nvim` at
`/Users/jonco/src/dotfiles/config/uwsm/default:4`.
The Neovim config does not set `clipboard=unnamedplus`, so bare `y` writes only
to a Neovim register. Visual `<leader>y` already yanks to the system `+`
clipboard at
`/Users/jonco/src/dotfiles/config/nvim/lua/config/keymaps.lua:56`.

Keep native copy mode as the fast inline path, and use editor scrollback when
selection needs to be precise or motion-rich.

## Current local behavior

The local config changes the prefix to `ctrl+space`, assigns `copy_mode` to
`prefix+v`, and deliberately disables `edit_scrollback`:

- `/Users/jonco/src/dotfiles/config/herdr/config.toml:19`
- `/Users/jonco/src/dotfiles/config/herdr/config.toml:26`
- `/Users/jonco/src/dotfiles/config/herdr/config.toml:61`

It also enables Herdr mouse capture and retains up to 10 MiB per pane:

- `/Users/jonco/src/dotfiles/config/herdr/config.toml:243`
- `/Users/jonco/src/dotfiles/config/herdr/config.toml:266`

`prefix+u` is a separate URL/file picker, not a general copy-mode replacement.
It calls `pane read --source recent-unwrapped --lines 100000`, extracts
candidates, and opens/copies the selected target:

- `/Users/jonco/src/dotfiles/bin/herdr-open:15`
- `/Users/jonco/src/dotfiles/bin/herdr-open:121`
- `/Users/jonco/src/dotfiles/bin/herdr-open:140`

There is one important mismatch in that helper: Herdr 0.7.3 caps `pane.read`
requests at 1,000 rows in the server regardless of the requested `--lines`
value. Therefore `--lines 100000` does not cover the full 10 MiB retained
buffer. See the v0.7.3
[`handle_pane_read` implementation](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/api/panes.rs#L1166-L1196).

## What native copy mode supports in 0.7.3

The complete dispatch table is in the v0.7.3
[`copy_mode.rs`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/copy_mode.rs#L83-L171).
There are no other copy-mode actions hidden in the config.

| Intent | Keys |
| --- | --- |
| Move one cell | `h/j/k/l`, arrow keys |
| Full page | `PageUp`/`PageDown`, `Ctrl-b`/`Ctrl-f` |
| Half page | `Ctrl-u`/`Ctrl-d` |
| History boundary | `g`/`G` |
| Row boundary | `0`/`Home`, `$`/`End`, `^` |
| Word motion | `w`, `b`, `e` |
| Blank-line/paragraph motion | `{`, `}` |
| Start characterwise selection | `v` or Space |
| Start linewise selection | `V` |
| Copy and exit | `y` or Enter |
| Cancel and exit | `q` or Esc |
| Enter normal Herdr prefix mode | the configured prefix |

The page size is pane height minus two rows; half-page movement uses half the
pane height. See
[`copy_mode_page_lines`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/copy_mode.rs#L692-L700).
Exiting restores the scroll offset that was active before entering copy mode,
and prefix-based pane/tab/workspace focus can temporarily leave and later
restore the source pane's copy context. See
[`exit_copy_mode`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/copy_mode.rs#L178-L196)
and
[`copy_mode_survives_prefix_action`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/navigate.rs#L1293-L1315).

### Where the Vim analogy stops

In 0.7.3, `w/b/e` inspect only the current visible terminal row; they do not
cross lines. The implementation reads one row, calculates a target inside it,
and returns without moving if that row has no next target:
[`copy_mode_word_motion`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/copy_mode.rs#L408-L430).
Punctuation is not treated like tmux's default word separators, which remains
tracked in open upstream
[#970](https://github.com/ogulcancelik/herdr/issues/970).

The following familiar Vim/tmux facilities are absent from the 0.7.3 dispatch
table:

- Search: `/`, `?`, `n`, `N`.
- WORD motions: `W`, `B`, `E`.
- Character-find motions: `f`, `F`, `t`, `T`, `;`, `,`.
- Screen-position motions: `H`, `M`, `L`.
- Counts and operator-pending commands such as `3w` or `yw`.
- Marks and jumps.
- Text objects.
- Selection-end swapping with `o`.
- Rectangular/visual-block selection with `Ctrl-v`.
- User-defined copy-mode key tables or commands.

Only characterwise and linewise state variants exist in 0.7.3; there is no
blockwise state:
[`CopyModeSelection`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/state.rs#L848-L861).
Internal keys are not represented in `[keys]`; only the entry action is a
`BindingConfig`, defaulting to `prefix+[`:
[`KeysConfig`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/config/model.rs#L379-L385)
and
[`Config::default`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/config/model.rs#L943-L956).
Direct custom commands are not dispatched while `Mode::Copy` is active, and a
prefix custom command cancels copy mode, so `[[keys.command]]` cannot fill in
missing motions.

There is also a v0.7.3 documentation/template defect: `copy_mode` is parsed and
defaults to `prefix+[`, but the static text emitted by `herdr --default-config`
omits it between `edit_scrollback` and the pane focus bindings:
[`src/main.rs`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/main.rs#L194-L204).
The explicit local `copy_mode = "prefix+v"` remains valid.

## Mouse and outer-terminal selection

With `ui.mouse_capture = true`, Herdr owns mouse gestures. Left drag starts a
pane selection, dragging into an edge autoscrolls through retained pane
history, and release copies immediately. Double-click copies a token. The
first-party lifecycle is implemented in
[`mouse.rs`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/mouse.rs#L628-L685)
and
[`mouse.rs`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/mouse.rs#L807-L832).
Long-selection autoscroll was added specifically for this workflow in
[#128](https://github.com/ogulcancelik/herdr/issues/128).

In 0.7.3 there is no setting to preserve a mouse highlight without overwriting
the clipboard. `ui.copy_on_select = false` arrived in v0.7.4; v0.7.5 fixed its
initial selection-persistence bug. See the official
[`CHANGELOG`](https://github.com/ogulcancelik/herdr/blob/v0.7.5/CHANGELOG.md#L31-L33)
and
[`CHANGELOG`](https://github.com/ogulcancelik/herdr/blob/v0.7.5/CHANGELOG.md#L66-L73).

Setting `mouse_capture = false` releases normal clicks and drags to the outer
terminal, while pane applications that request mouse reporting may still cause
capture. This is documented in the v0.7.3
[`--default-config` template](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/main.rs#L253-L263).
It is an escape hatch for visible text, not a richer Herdr copy mode: the outer
terminal sees Herdr's rendered TUI surface, not the hidden per-pane retained
buffer, and Herdr's own clickable/drag UI is lost. Terminal-specific
Shift-drag selection can similarly bypass mouse reporting, but it has no
Herdr/Vim motions.

Mouse and copy mode both operate on the terminal emulator's retained buffer.
They cannot manufacture history that a full-screen alternate-screen TUI never
placed there. Upstream closed the request for a tmux-style
`alternate-screen off` equivalent as not planned; the report demonstrates that
`pane read` can return only the current viewport for such applications:
[#1304](https://github.com/ogulcancelik/herdr/issues/1304).

## First-party ways to get richer selection

### 1. Re-enable `edit_scrollback` — recommended

Herdr's native action snapshots *all retained rows* with
`recent_text(usize::MAX)`, writes a mode-0600 temporary file, and opens
`$EDITOR` in a temporary overlay pane:

- [`open_focused_scrollback_in_editor`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/navigate.rs#L829-L895)
- [`write_scrollback_temp_file`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/app/input/navigate.rs#L1721-L1763)
- Unix [`scrollback_editor_argv`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/platform/macos.rs#L36-L43)

When the editor exits, Herdr removes the temporary file and the overlay command
pane closes. The original feature was explicitly designed for searching,
copying, annotating, or saving agent output in an editor:
[#122](https://github.com/ogulcancelik/herdr/issues/122).

Advantages:

- Full Neovim motions, search, visual character/line/block, text objects,
  marks, plugins, and mappings.
- Stable snapshot: new pane output cannot move the text being selected. This
  also avoids still-open native copy-mode bug
  [#680](https://github.com/ogulcancelik/herdr/issues/680).
- Full retained normal-screen history, not the public API's 1,000-row cap.
- Already first-party and already shipped in 0.7.3.

Limitations:

- It is a snapshot outside the live pane, not inline copy mode.
- Native `recent_text` preserves terminal display rows, so soft-wrapped lines
  appear as separate rows. The public `recent-unwrapped` reader can join them,
  but is capped at 1,000 rows.
- The temporary file is editable, although edits have no effect on the source
  pane and the file is deleted on exit.
- In this Neovim config, use visual `<leader>y` for the system clipboard; bare
  `y` stays in Neovim.
- Alternate-screen applications still have only whatever history the inner
  terminal actually retained.

### 2. Export with `herdr pane read`, then open Neovim or a pager

The public CLI supports:

```text
herdr pane read <pane_id> \
  [--source visible|recent|recent-unwrapped] \
  [--lines N] [--format text|ansi]
```

`recent-unwrapped` is valuable when prose or URLs were soft-wrapped; `ansi`
preserves styling for a renderer. The authoritative parser is
[`cli/pane.rs`](https://github.com/ogulcancelik/herdr/blob/v0.7.3/src/cli/pane.rs#L443-L507).

Two public implementations show the pattern:

- [`scrollback-nvim.sh`](https://github.com/ryanthedev/dot-config/blob/db16221ddd0f9522e65f6e622f11d0d8a0ea4493/herdr/scripts/scrollback-nvim.sh#L1-L58)
  zooms a throwaway pane, captures ANSI, detects a filetype, uses Baleia to
  render colors, and opens at the newest output.
- [`herdr-capture`](https://github.com/jeraldlyh/dotfiles/blob/3f037da89713a68e2f74e6322cf92423b3105e28/scripts/herdr-capture#L1-L16)
  captures unwrapped text, splits a pane, and launches Neovim.

Both are credible recipes, but neither beats native `edit_scrollback` for this
specific goal. Both go through the 1,000-row API cap; the second omits
`--lines`, so it gets the API default of only 80 rows. A custom version is
justified only for extra behavior such as ANSI colorization, auto-closing after
the first system-clipboard yank, unwrapped output, custom filetype detection,
or opening in a normal tab instead of Herdr's overlay.

The local `herdr-open` already demonstrates the safer custom-command context:
use `HERDR_ACTIVE_PANE_ID`, not the temporary command pane's `HERDR_PANE_ID`,
to read the pane that was focused when the binding fired.

### 3. Trial a richer third-party overlay

[`qq88976321/herdr-copy-search`](https://github.com/qq88976321/herdr-copy-search)
is the closest existing plugin to a richer inline copy mode. It adds regex
search, `n`/`N`, `v`/`V`, Vim word and paragraph motions, `iw`/`aw` and
`iW`/`aW` text objects, mouse selection, pattern extraction, and OSC 52
copying. It is a credible experiment if text objects and regex search matter
more than full history.

It is not tmux-grade or full Vim. Its own documentation excludes counts,
`f/F/t/T`, `W/B/E`, marks, viewport motions, and block selection from scope.
It also reads through Herdr's public pane API, so it can see at most 1,000
rows. The repository describes the project as a personal, AI-assisted tool
without support guarantees. It should therefore be bound alongside native
copy mode for a trial, not replace the recommended first-party paths
immediately.

Other plugins solve narrower selection problems:

- [`RooseveltAdvisors/herdr-leap`](https://github.com/RooseveltAdvisors/herdr-leap)
  adds EasyMotion-style character jumps into native copy mode and optional
  two-point region copying.
- [`hotchpotch/herdr-tiny-fingers`](https://github.com/hotchpotch/herdr-tiny-fingers)
  and [`rmarganti/herdr-pluck`](https://github.com/rmarganti/herdr-pluck)
  label visible URLs, paths, SHAs, IPs, and custom-regex matches for quick
  copying.

Those hint plugins are useful companions to `prefix+u`, but they select
recognizable visible tokens rather than arbitrary text with Vim motions.
Several require Herdr 0.7.4 or newer.

### 4. Use native mouse or terminal-native selection

Mouse drag is the fastest no-mode path and supports long-selection autoscroll,
but it provides no Vim motions and always copies on release in 0.7.3.
Disabling Herdr mouse capture gives the host terminal normal selection, at the
cost of Herdr's mouse UI and access to off-screen Herdr pane history. Neither
solves the keyboard-rich visual-selection request.

### 5. Outer terminal scrollback actions are not pane scrollback

Ghostty/Kitty/WezTerm scrollback pagers or "write scrollback to file" actions
operate on the outer terminal's buffer. When Herdr is the foreground TUI, that
buffer contains Herdr frames, not the focused pane's private Ghostty VT
history. They are therefore not substitutes for `edit_scrollback` or
`pane read`.

Running tmux inside a Herdr pane restores tmux's copy tables only for the nested
tmux session. It adds another persistence, pane, mouse, clipboard, and prefix
layer and does not improve Herdr's own pane buffer, so it is not a credible
default for this migration.

## What an upgrade changes

Upgrading from 0.7.3 to v0.7.5 materially improves native copy mode:

- v0.7.4 added literal smart-case `/` and `?` search, `n`/`N` repeat, match
  highlighting, and cross-line `w/b/e`.
- v0.7.4 fixed `$`/End to stop at the last visible character rather than the
  pane's right edge.
- v0.7.4 added `ui.copy_on_select`.
- v0.7.5 fixed retained highlighting when `copy_on_select = false`.

These are documented in the official v0.7.5
[`CHANGELOG`](https://github.com/ogulcancelik/herdr/blob/v0.7.5/CHANGELOG.md#L65-L93).
The current official
[`Keyboard` documentation](https://herdr.dev/docs/keyboard/#copy-mode)
describes the upgraded behavior, not the installed 0.7.3 behavior.

An upgrade does **not** make internal copy-mode keys configurable or add full
Vim semantics. The v0.7.5 dispatcher still hard-codes the mode table:
[`copy_mode.rs`](https://github.com/ogulcancelik/herdr/blob/v0.7.5/src/app/input/copy_mode.rs#L83-L202).
Open issues still cover punctuation-compatible word boundaries
([#970](https://github.com/ogulcancelik/herdr/issues/970)), copy view movement
under live output ([#680](https://github.com/ogulcancelik/herdr/issues/680)),
and full-width glyph movement
([#1000](https://github.com/ogulcancelik/herdr/issues/1000)).

Upstream considered tmux-thumbs/Flash-style visible-token hints, but the
requests were closed as not planned
([#863](https://github.com/ogulcancelik/herdr/issues/863),
[#1551](https://github.com/ogulcancelik/herdr/issues/1551)). Two July 26
"native pluck mode" pull requests were closed without merge
([#1887](https://github.com/ogulcancelik/herdr/pull/1887),
[#1892](https://github.com/ogulcancelik/herdr/pull/1892)); they are not an
available upstream solution.

## Recommended configuration direction

1. Upgrade Herdr from 0.7.3 to at least 0.7.5 for search, cross-line word
   movement, correct line-end motion, and optional non-copying mouse selection.
2. Keep native copy mode on `prefix+v` as the quick inline path.
3. Bind `edit_scrollback = "prefix+shift+v"` as the rich Neovim selection
   path. If the rich path must own `prefix+v`, move native copy mode to its
   upstream default `prefix+[`.
4. Keep `prefix+u` for its distinct URL/file picker job.
5. Trial `herdr-copy-search` on a separate chord only if its regex search,
   text objects, or pattern extraction justify its 1,000-row cap and lower
   maturity.
6. If the editor snapshot's wrapped rows become painful, build a small
   `recent-unwrapped` Neovim wrapper, accepting the current 1,000-row API cap,
   or propose a first-party unwrapped option for `edit_scrollback`.

This split is clearer than trying to approximate Vim by adding more Herdr
bindings: Herdr does not expose those bindings, while Neovim already supplies
the exact interaction model being sought.
