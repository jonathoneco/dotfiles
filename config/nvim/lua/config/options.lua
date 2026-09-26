vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Tab / Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- Appearance
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.colorcolumn = "80,120"
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 8
opt.completeopt = "menuone,noinsert,noselect"
vim.g.have_nerd_font = true

-- Behaviour
opt.hidden = true
opt.errorbells = false
opt.swapfile = true
opt.backup = false
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.autoread = true
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.autochdir = false
opt.iskeyword:append("-")
vim.opt.isfname:append("@-@")
opt.mouse = "a"
opt.showmode = false
opt.updatetime = 50
opt.timeoutlen = 800 -- Reduce key sequence timeout from default 1000ms

vim.filetype.add({
	extension = {
		templ = "templ",
		conf = "conf",
	},
})

-- folds
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99

-- Python host for molten.nvim
vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")
vim.g.enable_jupyter = false

-- Clipboard inside herdr: copies go out as OSC 52, which herdr forwards to
-- whichever terminal is viewing the pane (the Mac over a machine connection,
-- foot at the desk). herdr does not answer OSC 52 clipboard reads, so "+p
-- pastes nvim's own last yank; paste from the desktop with the terminal's
-- paste key. Setting this explicitly also stops nvim from finding no provider
-- in panes that have neither a display nor SSH_TTY.
if vim.env.HERDR_ENV == "1" then
	local osc52 = require("vim.ui.clipboard.osc52")
	local function paste_last_yank()
		return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
	end
	vim.g.clipboard = {
		name = "osc52-copy-only",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = paste_last_yank, ["*"] = paste_last_yank },
	}
end
