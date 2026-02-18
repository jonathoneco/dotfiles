# Welcome to Your New Developer Setup

You've just installed a collection of config files (called "dotfiles") that turns your plain terminal into a powerful, beautiful workspace. Instead of clicking through menus and reaching for the mouse, you'll fly through your work with keyboard shortcuts.

Here's what you're getting, in plain English:

- **tmux** - A window manager for your terminal. Split your screen, switch between projects, and pop up tools instantly. If you close your terminal by accident, everything is still there when you come back.
- **Neovim** - A keyboard-driven text editor that's blazing fast. Built-in fuzzy searching, git integration, and code intelligence. It feels weird for 15 minutes, then it feels like a superpower.
- **zsh** - Your command line, but better. Smarter autocomplete, quick directory jumping, and a clean prompt that shows you useful info at a glance.

**How long will this take?** Give yourself 30 minutes to get comfortable with the basics. You'll keep discovering new tricks for weeks after that. There's no rush - every shortcut you learn is a small upgrade to your workflow.

---

## Getting Set Up

### Prerequisites

Make sure you have these installed:

- `git`
- `tmux`
- `neovim` (v0.9 or later)
- `zsh`
- A [Nerd Font](https://www.nerdfonts.com/) (so icons display correctly in your terminal)

### Running the Bootstrap

The bootstrap script creates symbolic links from these config files to where your system expects them. Think of it as telling your computer: "Use *these* settings instead of the defaults."

```bash
git clone <repo-url> ~/src/dotfiles
cd ~/src/dotfiles
./bootstrap.sh
```

### Did It Work?

1. Open a new terminal - you should see tmux start automatically
2. Type `nvim` and press Enter - Neovim should open with a styled interface
3. Type `echo $SHELL` - it should show `/usr/bin/zsh` or similar

If something looks off, close everything and reopen your terminal. Many changes only take effect in a new session.

---

## Your Terminal - tmux Basics

### What Is tmux?

Think of tmux as having a desk with multiple monitors, except they're all inside your terminal. You can:

- Split your screen into side-by-side or stacked panels
- Create separate "tabs" for different tasks
- Switch between entire project workspaces
- Walk away and come back later - everything stays exactly where you left it

### The Prefix Key

Most tmux commands start by pressing **`Ctrl+Space`**, then a second key. This is your "hey tmux, listen up" signal. Throughout this guide, we'll write this as:

> `Ctrl+Space` then `x`

That means: hold Ctrl, tap Space, release both, then tap `x`.

### The Essentials - Your First 10 Minutes

These are the shortcuts you'll use every single day:

| What you want to do | How to do it |
|---|---|
| Split screen side-by-side | `Ctrl+Space` then `\` |
| Split screen top-and-bottom | `Ctrl+Space` then `-` |
| Move between splits | `Ctrl+Space` then `Ctrl+h/j/k/l` |
| Create a new tab (window) | `Ctrl+Space` then `c` |
| Switch between tabs | `Ctrl+Space` then `1`, `2`, `3`... |
| Close the current split | Type `exit` or press `Ctrl+d` |

The movement keys `h/j/k/l` map to directions: `h` = left, `j` = down, `k` = up, `l` = right. This is the same pattern used everywhere in this setup, so it's worth getting into your fingers early.

> **Try this:** Open your terminal. Press `Ctrl+Space` then `\` to create a side-by-side split. Now press `Ctrl+Space` then `Ctrl+l` to move to the right pane, and `Ctrl+Space` then `Ctrl+h` to move back left. Type `exit` in one pane to close it. You just managed your first tmux layout!

### Popup Tools - The Magic Trick

tmux can pop up a full-screen tool that disappears when you're done. No windows to manage, no tabs to close - it just appears, you use it, and it vanishes.

| Tool | Shortcut | What it does |
|---|---|---|
| **lazygit** | `Ctrl+Space` then `g` | A visual git interface - stage, commit, push, all without memorizing git commands |
| **File browser** | `Ctrl+Space` then `e` | Browse and manage files visually (ranger) |
| **System monitor** | `Ctrl+Space` then `H` | See what's using your CPU and memory (btop) |
| **Scratch terminal** | `Ctrl+Space` then `w` | A quick throwaway terminal that disappears when you're done |
| **lazydocker** | `Ctrl+Space` then `D` | Manage Docker containers (if you use Docker) |

> Note: That's a capital `H` for the system monitor (Shift+h) and capital `D` for lazydocker (Shift+d).

> **Try this:** Press `Ctrl+Space` then `g` to pop open lazygit. Look around - you can see your repo status, stage files, and write commits all from this one screen. Press `q` to close it and you're right back where you were.

### Project Switching - The Sessionizer

This is one of the most powerful features. Each project gets its own **session** - a completely separate workspace with its own splits, tabs, and terminal history. When you switch away and come back, everything is exactly where you left it.

- **`Ctrl+Space` then `Ctrl+s`** - Opens the sessionizer: a fuzzy finder that lets you pick any project and jump to it instantly

Think of sessions like separate desks for separate projects. You can have your web app on one desk, your API on another, and your dotfiles on a third - and teleport between them in a keystroke.

> **Try this:** Press `Ctrl+Space` then `Ctrl+s`. A list of your projects will appear. Start typing a name to filter, then press Enter to jump to it. Press `Ctrl+Space` then `Ctrl+s` again to jump back to where you were.

### What You Learned

- `Ctrl+Space` is your tmux prefix key
- `\` and `-` split your screen
- `Ctrl+h/j/k/l` (after the prefix) moves between splits
- `g`, `e`, `H`, `w`, `D` (after the prefix) pop up useful tools
- `Ctrl+s` (after the prefix) switches between project sessions
- Sessions persist - your work is always waiting for you

---

## Your Editor - Neovim Basics

### What Is Neovim?

Neovim is a text editor that works differently from what you're used to. Instead of reaching for the mouse, you tell it what to do with short keyboard commands. Instead of Ctrl+S to save, you type `:w`. Instead of clicking on a file to open it, you press `Space` then `sf` and start typing.

It feels unfamiliar at first. That's completely normal. After about 15 minutes of practice, the basics will start to click. After a week, you won't want to go back.

### The Leader Key

Similar to tmux's prefix key, many Neovim commands start with pressing **`Space`** (the spacebar). This is called the **leader key**. When you see:

> `Space` then `sf`

That means: tap the spacebar, then type `s` then `f`. It's quick and fluid once you're used to it.

> **Important:** `Ctrl+Space` is for tmux commands. `Space` alone (inside Neovim) is for editor commands. If you mix them up, just press `Esc` and try again.

### Modes - The One Thing You Must Understand

This is THE key concept that makes Neovim different. Your editor is always in one of several **modes**, and the same key does different things depending on the mode:

| Mode | What it's for | How to enter | How to leave |
|---|---|---|---|
| **Normal** | Navigating, copying, deleting, running commands | Press `Esc` | (you're already here) |
| **Insert** | Actually typing text | Press `i` | Press `Esc` or `Ctrl+c` |
| **Visual** | Selecting text | Press `v` | Press `Esc` |
| **Command** | Running editor commands | Press `:` | Press `Enter` or `Esc` |

Think of it like this: Normal mode is for *reading and navigating*. Insert mode is for *writing*. You switch between them like switching between a red pen (editing commands) and a pencil (writing text).

> **The golden rule:** If things feel weird, press `Esc`. This takes you back to Normal mode, which is your safe home base.

> **Try this:** Open a file with `nvim somefile.txt`. You start in Normal mode. Press `i` to enter Insert mode - now you can type freely. Type a sentence. Press `Esc` to go back to Normal mode. Press `i` again to keep typing. Get comfortable with this switch - it'll become second nature.

### The Essentials - Your First 10 Minutes

#### Moving Around

| What you want to do | How |
|---|---|
| Move the cursor | `h`/`j`/`k`/`l` (left/down/up/right) or arrow keys |
| Jump half a page down | `Ctrl+d` |
| Jump half a page up | `Ctrl+u` |
| Go to the top of the file | `gg` |
| Go to the bottom of the file | `G` |
| Go to a specific line number | `:<number>` then Enter |

> Arrow keys work fine! But `h/j/k/l` keeps your fingers on the home row. Try both and use whichever feels right.

#### Editing Basics

| What you want to do | How |
|---|---|
| Start typing (before cursor) | `i` |
| Start typing (after cursor) | `a` |
| Stop typing (back to Normal) | `Esc` or `Ctrl+c` |
| Undo | `u` |
| Redo | `Ctrl+r` |
| Save the file | `:w` then Enter |
| Quit | `:q` then Enter |
| Save and quit | `:wq` then Enter |
| Quit without saving | `:q!` then Enter |

> **Try this:** Open `nvim /tmp/practice.txt`. Press `i` to enter Insert mode, type a few lines of text. Press `Esc`. Type `:w` and Enter to save. Type `u` a few times to undo your edits. Type `Ctrl+r` to redo them. Type `:q` and Enter to quit.

### Finding Things - Your New Superpowers

This is where Neovim starts to shine. Every one of these opens a fuzzy finder - just start typing and it narrows down the results instantly.

| What you want to do | How |
|---|---|
| Find a file by name | `Space` then `sf` |
| Search text across all files | `Space` then `sg` |
| Open recently edited files | `Space` then `s.` |
| Search in the current file | `/` then type your search, then Enter |
| Browse files (file tree) | `\` (backslash key) |
| See your open files (buffers) | `Space` then `Space` |
| Check git status | `Space` then `gs` |
| Search all keybindings | `Space` then `s,` |

> When a fuzzy finder is open, use `Ctrl+j`/`Ctrl+k` to move up and down through results, and `Enter` to select.

> **Try this:** Open Neovim in any project folder. Press `Space` then `sf` and start typing part of a filename. Watch the list narrow down as you type. Press Enter to open the file. Now press `Space` then `sg` and search for a word you know is somewhere in the project. You just searched your entire codebase in seconds!

### Harpoon - Your Favorite Files

Harpoon lets you **pin** your most-used files and jump to them instantly with a number key. Think of it as bookmarks, but faster.

| What you want to do | How |
|---|---|
| Pin the current file | `Space` then `h` |
| See your pinned files | `Ctrl+h` |
| Jump to pinned file 1 | `Space` then `1` |
| Jump to pinned file 2 | `Space` then `2` |
| Jump to pinned file 3 | `Space` then `3` |
| Jump to pinned file 4 | `Space` then `4` |
| Jump to pinned file 5 | `Space` then `5` |

> **Try this:** Open a file you use often. Press `Space` then `h` to pin it. Open another file and pin that too. Now press `Space` then `1` to jump to the first pinned file, and `Space` then `2` to jump to the second. Instant teleportation between your key files!

### Code Intelligence

Neovim understands your code. It can tell you what a function does, jump to where something is defined, and suggest fixes. Don't worry about how this works under the hood - just know these shortcuts:

| What you want to do | How |
|---|---|
| See info about a symbol (hover) | `K` |
| Go to where something is defined | `gd` |
| Find all references to something | `Space` then `vrr` |
| See suggested fixes (code actions) | `Space` then `vca` |
| Rename a symbol everywhere | `Space` then `vrn` |
| See errors and warnings | `Space` then `sd` |
| Show diagnostic on current line | `Space` then `vd` |
| Next diagnostic | `]d` |
| Previous diagnostic | `[d` |

> **Try this:** Open a code file and put your cursor on a function name. Press `K` to see its documentation. Press `gd` to jump to where it's defined. These two shortcuts alone will save you hours of scrolling.

### Zen Mode

Sometimes you want to focus without distractions. Zen Mode strips away line numbers, narrows the view, and gives you a clean writing environment.

- **`Space` then `z`** - Toggle Zen Mode on and off

Great for writing prose, markdown, or just concentrating on a single piece of code.

### What You Learned

- `Esc` is your home base - press it when anything feels wrong
- `i` to type, `Esc` to stop typing
- `:w` to save, `:q` to quit
- `Space sf` finds files, `Space sg` searches text
- `\` opens the file browser
- `Space h` pins files, `Space 1-5` jumps to them
- `K` and `gd` are your code navigation essentials

---

## Your Shell - zsh Essentials

Your shell has been upgraded with some quality-of-life improvements that work automatically.

### The Prompt

Your prompt is powered by **Starship** - a fast, customizable prompt that shows you useful info at a glance: your current directory, git branch, and more. You don't need to configure anything - it just works.

### Smart Directory Navigation

Instead of typing long paths like `cd ~/projects/my-web-app/frontend`, you can use **zoxide**:

```bash
z my-web     # Jumps to ~/projects/my-web-app (or whatever matches)
z front      # If you've been there before, it knows where you mean
```

Zoxide learns from your habits. The more you visit a directory, the better it gets at guessing what you want.

### Handy Aliases

These shortcuts are set up for you:

| What you type | What it does |
|---|---|
| `vim` | Opens Neovim (not old vim) |
| `..` | Go up one directory |
| `...` | Go up two directories |
| `.3`, `.4`, `.5` | Go up three, four, five directories |
| `ll` | Detailed file listing with sizes |
| `myip` | Shows your external IP address |
| `back` | Return to the previous directory |

### Useful Functions

| What you type | What it does |
|---|---|
| `compress foldername` | Creates a `.tar.gz` archive of a folder |
| `decompress file.tar.gz` | Extracts a `.tar.gz` archive |
| `commitDotFiles "message"` | Quickly commit and push your dotfiles changes |

> **Try this:** Type `ll` to see a detailed file listing. Type `..` to go up a directory, then `back` to return. Try `z` followed by part of a project name to jump there instantly.

### What You Learned

- `z <name>` is your fast directory navigation
- `..`, `...`, `.3` etc. go up directory levels
- `vim` opens Neovim
- `commitDotFiles` saves your dotfiles changes

---

## Putting It All Together - Real Workflows

The real magic happens when you combine these tools. Here are some everyday scenarios:

### Starting Your Day

1. Open your terminal - tmux starts automatically
2. Press `Ctrl+Space` then `Ctrl+s` - the sessionizer opens
3. Type part of your project name, press Enter
4. You're dropped into the project directory with all your previous windows and splits intact

### Editing Code

1. Inside Neovim, press `Space` then `sf` - find and open a file
2. Make your edits
3. Press `Space` then `h` to pin the file for quick access later
4. Press `Ctrl+Space` then `g` to pop open lazygit
5. Stage your changes, write a commit message, and push - all visually

### Working on Multiple Projects

1. Press `Ctrl+Space` then `Ctrl+s` - switch to a different project
2. Work there for a while
3. Press `Ctrl+Space` then `Ctrl+s` - switch back. Everything is exactly where you left it

### Investigating Code

1. Press `Space` then `sg` to search all files for a keyword
2. Navigate to a result and press `gd` to jump to where something is defined
3. Press `K` to read its documentation
4. Press `Ctrl+Space` then `\` to split your tmux screen and run a terminal command alongside your editor

---

## Quick Reference Cheat Sheet

Print this page and tape it next to your monitor. After a week, you probably won't need it anymore.

### tmux (prefix: `Ctrl+Space`)

| Action | Keys |
|---|---|
| **Splits** | |
| Split side-by-side | `Ctrl+Space`, `\` |
| Split top-and-bottom | `Ctrl+Space`, `-` |
| Move between splits | `Ctrl+Space`, `Ctrl+h/j/k/l` |
| **Windows** | |
| New window (tab) | `Ctrl+Space`, `c` |
| Switch to window N | `Ctrl+Space`, `1`-`9` |
| **Popups** | |
| Lazygit | `Ctrl+Space`, `g` |
| File browser (ranger) | `Ctrl+Space`, `e` |
| System monitor (btop) | `Ctrl+Space`, `H` |
| Scratch terminal | `Ctrl+Space`, `w` |
| Lazydocker | `Ctrl+Space`, `D` |
| **Sessions** | |
| Sessionizer (switch project) | `Ctrl+Space`, `Ctrl+s` |
| **Other** | |
| Enter scroll/copy mode | `Ctrl+Space`, `v` |
| Reload tmux config | `Ctrl+Space`, `r` |

### Neovim (leader: `Space`)

| Action | Keys |
|---|---|
| **Modes** | |
| Enter Insert mode | `i` or `a` |
| Back to Normal mode | `Esc` or `Ctrl+c` |
| Visual select | `v` |
| **Files** | |
| Save | `:w` Enter |
| Quit | `:q` Enter |
| Save and quit | `:wq` Enter |
| Quit without saving | `:q!` Enter |
| **Search and Navigation** | |
| Find file by name | `Space`, `sf` |
| Search text in all files | `Space`, `sg` |
| Recent files | `Space`, `s.` |
| Search in current file | `/` then type, Enter |
| File tree (Oil) | `\` |
| Open buffers | `Space`, `Space` |
| Git status | `Space`, `gs` |
| Search all keybindings | `Space`, `s,` |
| **Harpoon (pinned files)** | |
| Pin current file | `Space`, `h` |
| Show pinned files | `Ctrl+h` |
| Jump to pinned 1-5 | `Space`, `1`-`5` |
| **Code Intelligence** | |
| Hover documentation | `K` |
| Go to definition | `gd` |
| Find references | `Space`, `vrr` |
| Code actions | `Space`, `vca` |
| Rename symbol | `Space`, `vrn` |
| Diagnostics (all) | `Space`, `sd` |
| Diagnostic (this line) | `Space`, `vd` |
| **Movement** | |
| Half-page down/up | `Ctrl+d` / `Ctrl+u` |
| Top/bottom of file | `gg` / `G` |
| Undo / Redo | `u` / `Ctrl+r` |
| **Other** | |
| Zen Mode | `Space`, `z` |

### Shell

| Action | Command |
|---|---|
| Smart jump to a directory | `z <name>` |
| Go up directories | `..`, `...`, `.3`, `.4`, `.5` |
| Detailed file listing | `ll` |
| Your external IP | `myip` |
| Compress a folder | `compress foldername` |
| Extract an archive | `decompress file.tar.gz` |
| Commit dotfiles changes | `commitDotFiles "message"` |

---

## Where to Go From Here

You now know enough to be productive. Here's how to keep growing at your own pace:

- **Neovim's built-in tutorial** - Type `:Tutor` inside Neovim for an interactive lesson on the fundamentals
- **Search all keybindings** - Press `Space` then `s,` to browse every available shortcut. Great for discovering features you didn't know existed
- **tmux copy mode** - Press `Ctrl+Space` then `v` to scroll through terminal output and copy text. Use `v` to start a selection and `y` to copy
- **One shortcut per week** - Don't try to learn everything at once. Pick one new shortcut each week and use it until it's automatic. Small, steady progress beats cramming

You've got this. Every expert started exactly where you are now. The tools are powerful, the learning curve is real, but every shortcut you learn makes your next day a little smoother. Welcome aboard!
