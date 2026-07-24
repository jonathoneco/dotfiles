# Vim selection over cmux scrollback

## Conclusion

Someone has built the practical workaround: [`imroc/dotfiles`'s `cmux-scrollback-copy`](https://github.com/imroc/dotfiles/blob/main/.local/bin/cmux-scrollback-copy) captures the focused cmux terminal's complete scrollback, creates a disposable tab in the same pane, opens the capture read-only in Neovim, and closes the tab after the first yank. This gives real Vim motions and visual selection, but it is an external scrollback viewer, not an enhancement to cmux's inline copy mode.

There is no published cmux extension that replaces or extends the terminal copy-mode state machine. The cleanest result available today is to adapt that script for this machine and invoke it outside the foreground terminal process.

## What exists

### Native cmux copy mode

cmux ships `toggleTerminalCopyMode` (default `Cmd+Shift+M`) and permits rebinding it in `cmux.json`. Its upstream tracking issue still describes parity with Alacritty/tmux as unfinished: word motions, character-find motions, block selection, operator-pending yanks, marks, and viewport positioning remain planned work. [`V`/`Y` support was merged later](https://github.com/manaflow-ai/cmux/pull/6221), but visual-line selection is implemented over absolute terminal screen rows. Sources: [configuration reference](https://cmux.com/docs/configuration), [open parity issue #846](https://github.com/manaflow-ai/cmux/issues/846), [fix PR #6221](https://github.com/manaflow-ai/cmux/pull/6221).

This is the mode already tested. It remains terminal-grid selection rather than a full Vim/tmux copy-mode model.

### Working Neovim viewer

The public [`cmux-scrollback-copy` script](https://github.com/imroc/dotfiles/blob/main/.local/bin/cmux-scrollback-copy) performs this flow:

1. `cmux identify --json --no-caller` finds the focused terminal surface and its pane.
2. `cmux capture-pane --surface "$surface" --scrollback` writes the full capture to a temporary file.
3. `cmux new-surface --pane "$pane"` creates a tab alongside the source terminal.
4. It focuses that tab and sends an `nvim -R` command.
5. A one-shot `TextYankPost` autocmd exits Neovim; the shell then removes the temporary file and exits, closing the tab.

The author's [Karabiner rule](https://github.com/imroc/dotfiles/blob/main/.config/karabiner/karabiner.json) invokes the script with `Cmd+I` only while cmux is frontmost. That detail matters: a cmux `command` action does not execute out of process. Upstream's action executor either sends the command text to the current terminal or creates a new terminal with that text as initial input ([source](https://github.com/manaflow-ai/cmux/blob/005d453f5281e24d71f8bab286c6a52805b16142/Sources/CmuxConfigExecutor.swift#L116-L138)). Sending the launcher into the current surface is unsafe when Codex, Claude, Neovim, or another TUI owns its input; starting it in a new tab loses the identity of the source surface.

The underlying capture operation is supported, not a private hack. cmux documents `capture-pane` as a terminal-read command, while its tmux-compatible `copy-mode` command remains only a placeholder ([CLI contract](https://github.com/manaflow-ai/cmux/blob/005d453f5281e24d71f8bab286c6a52805b16142/docs/cli-contract.md#L274-L291)). Current Nightly exposes:

```text
cmux capture-pane [--workspace <id|ref|index>] [--surface <id|ref|index>]
                  [--window <id|ref|index>] [--scrollback] [--lines <n>]
```

### Ghostty's export action

Ghostty provides `write_scrollback_file:{open,copy,paste}`. It can write all scrollback to a temporary file, but `open` uses the OS default editor and the action cannot launch an arbitrary terminal command such as `nvim`. It is therefore a useful primitive, not a tmux-copy-mode replacement. Source: [Ghostty keybinding action reference](https://ghostty.org/docs/config/keybind/reference#write_scrollback_file).

## Limitations of the runnable candidate

- It is a snapshot: new output arriving after capture is absent.
- Selection happens in a separate tab, not inline over the live terminal.
- Plain captured text cannot perfectly preserve terminal semantics such as logical pre-wrap lines, arbitrary cursor-addressed TUI painting, or all styling.
- The published script hard-codes stable cmux at `/Applications/cmux.app/...`; this machine uses `/Applications/cmux NIGHTLY.app/...`.
- Its Karabiner condition matches only stable bundle ID `com.cmuxterm.app`; Nightly uses `com.cmuxterm.app.nightly`.
- It depends on Bash, Python, Neovim, and Karabiner, and uses a prompt-character polling heuristic before sending the Neovim command.
- Auto-exit on the first yank is convenient for copying once but should be optional for multi-yank review.

## Recommendation

Adapt the `imroc` workflow rather than build a terminal-mode extension. Keep cmux's native copy mode for quick inline copies, and bind a Nightly-aware `cmux-scrollback-copy` launcher for full Vim selection. The local version should:

- discover the active cmux CLI/socket rather than hard-code stable cmux;
- match both stable and Nightly bundle IDs;
- use the focused surface returned by `identify --no-caller`;
- retain strict cleanup on capture, surface-creation, or editor failure;
- make “exit after first yank” configurable;
- pass `shellcheck` and use the existing dotfiles `bin/` package.

This is the closest current equivalent to tmux Vi copy mode without running local tmux. It uses stable cmux automation primitives and keeps the richer selection behavior in Neovim, where it already exists.
