-- General
vim.opt.updatetime = 50

-- Visuals
vim.g.have_nerd_font = true

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.wrap = false

vim.opt.hlsearch = false

vim.opt.termguicolors = true

vim.opt.signcolumn = "yes"

vim.opt.colorcolumn = "80,120"

-- Lint
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.filetype.add({
    extension = {
        templ = 'templ',
        conf = 'conf',
    }
})

-- Buffers
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.isfname:append("@-@")

vim.opt.splitright = true
vim.opt.splitbelow = true

-- Navigation
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.mouse = "a"

-- NetRW settings
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
