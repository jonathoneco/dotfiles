-- All keymaps converted to instant function calls for better responsiveness

-- Buffer Navigation - converted to instant function calls
vim.keymap.set("n", "<leader>bn", function()
	vim.cmd("bnext")
end, { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", function()
	vim.cmd("bprevious")
end, { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bb", function()
	vim.cmd("e #")
end, { desc = "Switch to other buffer" })
vim.keymap.set("n", "<leader>`", function()
	vim.cmd("e #")
end, { desc = "Switch to other buffer" })

-- nvim-tree toggle (already converted)
-- vim.keymap.set("n", "<leader>m", function() vim.cmd("NvimTreeFocus") end, { desc = "Focus nvim-tree" })
vim.keymap.set("n", "\\", function()
	vim.cmd("NvimTreeToggle")
end, { noremap = true, silent = true, desc = "Toggle nvim-tree" })

-- Fuzzy Finder Navigation - converted to instant function calls
-- vim.keymap.set("n", "<leader>ff", function() vim.cmd("FzfLua files") end, { desc = "Find files" })
-- vim.keymap.set("n", "<leader>fg", function() vim.cmd("FzfLua grep_project") end, { desc = "Grep project" })
-- vim.keymap.set("n", "<leader>fb", function() vim.cmd("FzfLua buffers") end, { desc = "Find buffers" })
-- vim.keymap.set("n", "<leader>fx", function() vim.cmd("FzfLua diagnostics_document") end, { desc = "Document diagnostics" })
-- vim.keymap.set("n", "<leader>fX", function() vim.cmd("FzfLua diagnostics_workspace") end, { desc = "Workspace diagnostics" })
-- vim.keymap.set("n", "<leader>fc", function() vim.cmd("FzfLua git_bcommits") end, { desc = "Git commits for buffer" })
-- vim.keymap.set("n", "<leader>fl", function() vim.cmd("FzfLua lsp_references") end, { desc = "LSP references" })

-- General
local map = vim.keymap.set
vim.g.mapleader = " " -- Set <leader> to space

map("i", "<C-c>", "<Esc>", { desc = "Exit insert mode (Ctrl+C)" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard (insert mode)" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line(s) down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line(s) up" })

-- Join lines while keeping cursor position
map("n", "J", "mzJ`z", { desc = "Join lines (preserve cursor)" })

-- Half-page jumps centered
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })

-- Centered next/previous search results
map("n", "n", "nzzzv", { desc = "Next search (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search (centered)" })

-- Formatting
-- map("n", "<leader>f", function()
--     require("conform").format({ bufnr = 0 })
-- end, { desc = "Format buffer with Conform" })
map("n", "=ap", "ma=ap'a", { desc = "Indent paragraph and return to position" })

-- Paste over selection without yanking it
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Clipboard paste/yank
map({ "n", "v" }, "<leader>P", '"+p', { desc = "Paste from clipboard" })
map({ "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

map("n", "Q", "<nop>", { desc = "Disable Q (ex mode)" })

-- tmux passthrough
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Launch tmux sessionizer" })
-- map("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 1 --vsplit<CR>", { desc = "Split tmux vertically (sessionizer)" })
-- map("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "New tmux session (sessionizer)" })

-- Jump through diagnostics or location lists
map("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Next quickfix (centered)" })
map("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Previous quickfix (centered)" })
map("n", "<leader>k", "<cmd>lprev<CR>zz", { desc = "Next location list item (centered)" })
map("n", "<leader>j", "<cmd>lnext<CR>zz", { desc = "Previous location list item (centered)" })

-- Utils
map("n", "<C-s>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Go Keymaps
map("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { desc = "Insert err check with return" })
map("n", "<leader>ea", 'oassert.NoError(err, "")<Esc>F";a', { desc = "Insert assert.NoError(err)" })
map(
	"n",
	"<leader>ef",
	'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj',
	{ desc = "Insert err check with log.Fatalf" }
)
map(
	"n",
	"<leader>el",
	'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i',
	{ desc = "Insert err check with logger.Error" }
)

-- Add undo break-points
map("i", ",", ",<c-g>u", { desc = "Undo breakpoint after comma" })
map("i", ".", ".<c-g>u", { desc = "Undo breakpoint after period" })
map("i", "?", ".<c-g>u", { desc = "Undo breakpoint after question mark" })
map("i", "!", ".<c-g>u", { desc = "Undo breakpoint after exclamation mark" })
map("i", ";", ";<c-g>u", { desc = "Undo breakpoint after semicolon" })

-- better indenting
map("v", "<", "<gv", { desc = "Indent left (preserve selection)" })
map("v", ">", ">gv", { desc = "Indent right (preserve selection)" })

-- commenting
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })

-- Copying buffer paths
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Copy relative path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Copy full path", silent = true })

-- Create splits
map("n", "<leader>\\", "<cmd>vnew<cr>", { desc = "Vertical Split", silent = true })
map("n", "<leader>-", "<cmd>new<cr>", { desc = "Horizontal Split", silent = true })

-- Resize splits with alt+cursor keys
map({ "n", "i", "v" }, "<A-j>", "<nop>", { desc = "Disabled" })
map({ "n", "i", "v" }, "<A-k>", "<nop>", { desc = "Disabled" })
map({ "n", "i", "v" }, "<M-j>", "<nop>", { desc = "Disabled" })
map({ "n", "i", "v" }, "<M-k>", "<nop>", { desc = "Disabled" })

map("n", "<M-Up>", ":resize +2<CR>", { desc = "Resize split: increase height" })
map("n", "<M-Down>", ":resize -2<CR>", { desc = "Resize split: decrease height" })
map("n", "<M-Left>", ":vertical resize -2<CR>", { desc = "Resize split: decrease width" })
map("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "Resize split: increase width" })

-- Fun
map("n", "<leader>ca", function()
	require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular Automaton: Make It Rain" })

map("n", "<leader>ct", "<cmd>CloakToggle<CR>", { desc = "Toggle Cloak (secret masking)" })

vim.keymap.set('n', '<leader>cs', function()
  require('config.themes').select_theme()
end, { desc = 'Telescope theme selector (live preview)' })


-- Comments
-- if vim.env.TMUX ~= nil then
-- 	api.nvim_set_keymap("n", "<C-_>", "gtc", { noremap = false })
-- 	api.nvim_set_keymap("v", "<C-_>", "goc", { noremap = false })
-- else
-- 	api.nvim_set_keymap("n", "<C-/>", "gtc", { noremap = false })
-- 	api.nvim_set_keymap("v", "<C-/>", "goc", { noremap = false })
-- end
