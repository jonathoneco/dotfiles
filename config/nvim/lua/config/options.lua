-- ### Clipboard, Undo, Swap
-- @module vim
vim.schedule(
    function() -- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can increase startup-time.
        vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
    end
)
--
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0

vim.opt.undofile = true                                     -- Save undo history
vim.opt.undolevels = 10000
vim.opt.undoreload = 10000

vim.opt.swapfile = false
vim.opt.backup = false      -- creates a backup file
vim.opt.writebackup = false -- if a file is being edited by another program

-- ### File Handling and Editing Behavior
vim.filetype.add {
  extension = {
    templ = 'templ',
  },
}

vim.opt.autowrite = true           -- Enable auto write
vim.opt.fixendofline = false       -- Prevent Nvim from removing end of file new line

vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.tabstop = 2                -- Number of spaces tabs count for
vim.opt.shiftwidth = 2             -- Size of an indent
vim.opt.shiftround = true          -- Round indent
vim.opt.smartindent = true         -- Insert indents automatically
vim.opt.breakindent = true         -- Enable break indent

vim.opt.linebreak = true           -- Wrap lines at convenient points
vim.opt.wrap = true                -- Disable line wrap
vim.opt.whichwrap:append("<>[]hl") -- go to previous/next line with h,l

vim.opt.virtualedit = "block"      -- Allow cursor to move where there is no text in visual block mode
vim.opt.jumpoptions = "view"

vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.formatoptions = "jcroqlnt" -- tcqj
vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.confirm = false -- Confirm to save changes before exiting modified buffer

-- ### UI & Visuals

vim.opt.number = true         -- Print line number
vim.opt.relativenumber = true -- Relative line numbers

vim.opt.ruler = false         -- Disable the default ruler
vim.opt.cursorline = true     -- Enable highlighting of the current line
vim.opt.colorcolumn = "80,120"
vim.opt.showtabline = 0       -- 0: never, 1: only if there are at least two tab pages, 2: always
vim.opt.laststatus = 3        -- global statusline
vim.opt.signcolumn = "yes"    -- Always show the signcolumn, otherwise it would shift the text each time

local loaded, _ = pcall(require, "snacks")
if loaded then
    vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
end

vim.opt.cmdheight = 1 -- 0 = off, more space in the neovim command line for displaying messages

vim.opt.mouse = "a"   -- Enable mouse mode
vim.opt.mousescroll = "ver:1,hor:0"

vim.opt.termguicolors = true -- True color support
vim.opt.winminwidth = 5      -- Minimum window width

vim.opt.sidescrolloff = 8    -- Columns of context
vim.opt.scrolloff = 4        -- Lines of context

vim.opt.conceallevel = 0     -- so that `` is visible in markdown files
vim.opt.diffopt = "filler,internal,closeoff,algorithm:histogram,context:5,linematch:60,algorithm:histogram"

vim.g.trouble_lualine = true -- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.g.snacks_animate = false

vim.opt.showmode = false -- Dont show mode since we have a statusline

-- ### Search & Substitute

vim.opt.ignorecase = true      -- Ignore case
vim.opt.smartcase = true       -- Don't ignore case with capitals
vim.opt.inccommand = "nosplit" -- preview incremental substitute
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"

-- ### Performance & Responsiveness

vim.opt.timeoutlen = 300 -- Lower than default (1000) to quickly trigger which-key
vim.opt.updatetime = 200 -- Save swap file and trigger CursorHold
vim.opt.smoothscroll = true

-- ### UI Symbols & Formatting

vim.opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }
vim.opt.list = true                  -- Show some invisible characters (tabs...
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.g.have_nerd_font = true          -- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.markdown_recommended_style = 0 -- Fix markdown indentation settings

-- ### Language & Spelling

vim.opt.spelllang = { "en" }
vim.opt.iskeyword:append({ "_", "-" })

-- ### Window, Split, & Popup Behavior

vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "screen"

vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.pumblend = 10  -- Popup blend

-- ### Folding

vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"

-- ### Misc

vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
-- Ensure I dont freak out by hitting the cap w when exiting
vim.cmd([[
  cnoreabbrev Wq wq
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev W w
  cnoreabbrev Q q
]])
