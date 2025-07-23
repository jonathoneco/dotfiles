-- Leader Mapping
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Visuals
vim.g.have_nerd_font = true
vim.g.markdown_recommended_style = 0 -- Fix markdown indentation settings
vim.opt.termguicolors = true

vim.opt.showmode = false

vim.opt.wrap = false

vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.pumblend = 10  -- Popup blend

-- Save undo history
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.undoreload = 10000

-- Cursor, Splits and Navigation
vim.opt.mouse = 'a'
vim.opt.mousescroll = "ver:1,hor:0"

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"

vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

vim.opt.whichwrap:append("<>[]hl") -- go to previous/next line with h,l

-- White Space
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.shiftround = true

vim.opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Signcolumn
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = "80,120"

-- Misc
vim.opt.isfname:append '@-@'

vim.opt.updatetime = 30
vim.opt.timeoutlen = 300
vim.opt.smoothscroll = true

vim.opt.inccommand = 'nosplit'
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"

vim.opt.cursorline = true

vim.opt.confirm = true

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.g.config_dir = os.getenv 'HOME' .. '/.config/nvim/config'

vim.opt.swapfile = false
vim.opt.backup = false      -- creates a backup file
vim.opt.writebackup = false -- if a file is being edited by another program

-- File Handling
vim.filetype.add {
  extension = {
    templ = 'templ',
  },
}

vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.formatoptions = "jcroqlnt" -- tcqj
vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.confirm = false    -- Confirm to save changes before exiting modified buffer

vim.opt.laststatus = 3     -- global statusline
vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time

vim.opt.diffopt = "filler,internal,closeoff,algorithm:histogram,context:6,linematch:60,algorithm:histogram"

vim.g.trouble_lualine = true -- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.opt.showmode = false     -- Dont show mode since we have a statusline

-- Language & Spelling

vim.opt.spelllang = { "en" }
vim.opt.iskeyword:append({ "_", "-" })

-- Folding

vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"

-- Misc

vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
-- Ensure I dont freak out by hitting the cap w when exiting
vim.cmd([[
  cnoreabbrev Wq wq
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev W w
  cnoreabbrev Q q
]])

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
