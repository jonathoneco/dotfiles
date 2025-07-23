-- General
local map = vim.keymap.set
vim.g.mapleader = " "
map("i", "<C-c>", "<Esc>")
map("n", "<leader>pv", vim.cmd.Ex)

vim.api.nvim_set_keymap("n", "<leader>tf", "<Plug>PlenaryTestFile", { noremap = false, silent = false })

map("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- Move selected lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Move selected lines in visual mode
map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Formats paragraph without losing location
map("n", "=ap", "ma=ap'a")

-- Paste over without yanking
map("x", "<leader>P", [["_dP]])

-- Paste from clipboard
map({ "n", "v" }, "<leader>p", "\"+p")

-- Yank to clipboard
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map({ "n", "v" }, "<leader>d", "\"_d")

map("n", "Q", "<nop>")

-- tmux passthrough
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
map("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 1 --vsplit<CR>")
map("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
map("n", "<leader>f", function()
    require("conform").format({ bufnr = 0 })
end)

-- Jump through diagnostics or location lists
map("n", "<C-k>", "<cmd>cnext<CR>zz")
map("n", "<C-j>", "<cmd>cprev<CR>zz")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Utils
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Go Keymaps
map(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

map(
    "n",
    "<leader>ea",
    "oassert.NoError(err, \"\")<Esc>F\";a"
)

map(
    "n",
    "<leader>ef",
    "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj"
)

map(
    "n",
    "<leader>el",
    "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i"
)

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

-- Copying buffer paths
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Relative Path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Full Path", silent = true })

-- Switch to other buffer
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

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


-- Fun
map("n", "<leader>ca", function()
    require("cellular-automaton").start_animation("make_it_rain")
end)

map('n', '<leader>ct', '<cmd>CloakToggle<CR>', { desc = 'Cloak Toggle' })
