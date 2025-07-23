---@module "snacks"

-------------------------------------------------------------------------------
-- General Keybindings, not plugin specific
-------------------------------------------------------------------------------
local opts = { silent = true }
local map = vim.keymap.set

-- Move selected lines in visual mode
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- Insert lines above/below without leaving normal mode
map("n", "oo", "o<Esc>k", opts)
map("n", "OO", "O<Esc>j", opts)

-- Add line break and jump to start
map("n", "<Enter>", "a<Enter><Esc>^", opts)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- commenting
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })

-------------------------------------------------------------------------------
-- Copy / Paste
-------------------------------------------------------------------------------
-- Use x and Del key for black hole register
map("", "<Del>", '"_x', opts)
map("", "x", '"_x', opts)

-------------------------------------------------------------------------------
-- Escape
-------------------------------------------------------------------------------
-- Map ctrl-c to esc
map("i", "<C-c>", "<esc>", opts)

-- Remove highlighting
map("n", "<esc><esc>", "<esc><cmd>noh<cr><esc>", opts)

-------------------------------------------------------------------------------
-- Buffers
-------------------------------------------------------------------------------
-- Print the current buffer type
map({ "n", "t", "v", "i", "" }, "<C-x>", "<cmd>echo &filetype<cr>", opts)

-- Copying buffer paths
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Relative Path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Full Path", silent = true })

-- Moving Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Switch to other buffer
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Deleting buffers
map("n", "<c-w>", "<cmd>bd<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-------------------------------------------------------------------------------
-- Splits
-------------------------------------------------------------------------------
-- Create splits
map("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Vertical Split", silent = true })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Horizontal Split", silent = true })

-- Resize splits with alt+cursor keys
map({ "n", "i", "v" }, "<A-j>", "<nop>")
map({ "n", "i", "v" }, "<A-k>", "<nop>")
map({ "n", "i", "v" }, "<M-j>", "<nop>")
map({ "n", "i", "v" }, "<M-k>", "<nop>")

map("n", "<M-Up>", ":resize +2<CR>", opts)
map("n", "<M-Down>", ":resize -2<CR>", opts)
map("n", "<M-Left>", ":vertical resize -2<CR>", opts)
map("n", "<M-Right>", ":vertical resize +2<CR>", opts)

-------------------------------------------------------------------------------
-- Terminal
-------------------------------------------------------------------------------
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-------------------------------------------------------------------------------
-- Navigation
-------------------------------------------------------------------------------
-- Centers various jumping motions
map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-------------------------------------------------------------------------------
-- Clipboard
-------------------------------------------------------------------------------
map('x', '<leader>p', [["_dP]], { desc = 'Paste over without yanking' })

map({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
map('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })

map({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete without yanking' })

-------------------------------------------------------------------------------
-- tmux passthrough
-------------------------------------------------------------------------------
map('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>', { desc = 'Open tmux sessionizer' })
map('n', '<leader>f', function()
  require('conform').format { bufnr = 0 }
end, { desc = 'Format current buffer' })

map('n', '<C-k>', '<cmd>cnext<CR>zz', { desc = 'Previous quickfix list item' })
map('n', '<C-j>', '<cmd>cprev<CR>zz', { desc = 'Next quickfix list item' })
map('n', '<leader>k', '<cmd>lprev<CR>zz', { desc = 'Previous location list item' })
map('n', '<leader>j', '<cmd>lnext<CR>zz', { desc = 'Next location list item' })

map('n', '<C-s>', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = 'Substitute word under cursor globally' })

map('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'Make file executable' })

-------------------------------------------------------------------------------
-- Go
-------------------------------------------------------------------------------
map('n', '<leader>ee', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>')

map('n', '<leader>ea', 'oassert.NoError(err, "")<Esc>F";a')

map('n', '<leader>ef', 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj')

map('n', '<leader>el', 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i')

-------------------------------------------------------------------------------
-- Misc / QOL
-------------------------------------------------------------------------------
map('n', '<leader>fs', function()
  require('custom.themes').select_theme()
end, { desc = 'Telescope theme selector (live preview)' })

map('n', '<leader>fa', function()
  require('cellular-automaton').start_animation 'make_it_rain'
end, { desc = 'Make it rain 🌧️' })

map('n', '<leader>ft', '<cmd>CloakToggle<CR>', { desc = 'Cloak Toggle' })

map('n', '<leader>fs', function()
  vim.cmd 'so'
end, { desc = 'Source Neovim Config' })

map('n', 'Q', '<nop>')

map('n', '=ap', "ma=ap'a")
