-- Leader Mapping
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Line Numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Visuals
vim.g.have_nerd_font = false

vim.opt.showmode = false

vim.opt.wrap = false

-- Save undo history
vim.o.undofile = true
vim.o.undodir = vim.fn.expand('~/.vim/undodir')

-- Cursor, Splits and Navigation
vim.opt.mouse = 'a'

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.scrolloff = 8

-- White Space
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Undo history
vim.opt.undofile = true
vim.opt.undodir = os.getenv 'HOME' .. '/.vim/undodir'

-- Search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = '80'

-- Misc
vim.opt.isfname:append '@-@'

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

vim.opt.inccommand = 'split'

vim.opt.cursorline = true

vim.opt.confirm = true

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
