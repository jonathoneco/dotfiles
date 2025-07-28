-- General
local map = vim.keymap.set
vim.g.mapleader = " " -- Set <leader> to space

map("i", "<C-c>", "<Esc>", { desc = "Exit insert mode (Ctrl+C)" })

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
map("n", "<leader>f", function()
    require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer with Conform" })
map("n", "=ap", "ma=ap'a", { desc = "Indent paragraph and return to position" })

-- Paste over selection without yanking it
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Clipboard paste/yank
map({ "n", "v" }, "<leader>P", "\"+p", { desc = "Paste from clipboard" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", "\"_d", { desc = "Delete without yanking" })

map("n", "Q", "<nop>", { desc = "Disable Q (ex mode)" })

-- tmux passthrough
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Launch tmux sessionizer" })
map("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 1 --vsplit<CR>", { desc = "Split tmux vertically (sessionizer)" })
map("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "New tmux session (sessionizer)" })

-- Jump through diagnostics or location lists
map("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix (centered)" })
map("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix (centered)" })
map("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location list item (centered)" })
map("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location list item (centered)" })

-- Utils
map("n", "<C-s>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Go Keymaps
map("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { desc = "Insert err check with return" })
map("n", "<leader>ea", "oassert.NoError(err, \"\")<Esc>F\";a", { desc = "Insert assert.NoError(err)" })
map("n", "<leader>ef", "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj",
    { desc = "Insert err check with log.Fatalf" })
map("n", "<leader>el", "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i",
    { desc = "Insert err check with logger.Error" })

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

-- Switch to other buffer
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Create splits
map("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Vertical Split", silent = true })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Horizontal Split", silent = true })

-- Resize splits with alt+cursor keys
map({ "n", "i", "v" }, "<A-j>", "<nop>") -- Disabled
map({ "n", "i", "v" }, "<A-k>", "<nop>")
map({ "n", "i", "v" }, "<M-j>", "<nop>")
map({ "n", "i", "v" }, "<M-k>", "<nop>")

map("n", "<M-Up>", ":resize +2<CR>", { desc = "Resize split: increase height" })
map("n", "<M-Down>", ":resize -2<CR>", { desc = "Resize split: decrease height" })
map("n", "<M-Left>", ":vertical resize -2<CR>", { desc = "Resize split: decrease width" })
map("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "Resize split: increase width" })


-- Fun
map("n", "<leader>ca", function()
    require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular Automaton: Make It Rain" })

map("n", "<leader>ct", "<cmd>CloakToggle<CR>", { desc = "Toggle Cloak (secret masking)" })
