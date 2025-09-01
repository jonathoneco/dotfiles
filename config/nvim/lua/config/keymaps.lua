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
vim.keymap.set("n", "\\", function() vim.cmd("Oil") end, { desc = "F:le Tree" })
-- vim.keymap.set("n", "|", function()
--     vim.cmd("NvimTreeToggle")
-- end, { noremap = true, silent = true, desc = "Toggle nvim-tree" })

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

-- Jump through diagnostics or location lists
map("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix (centered)" })
map("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Next quickfix (centered)" })
map("n", "<leader>k", "<cmd>lprev<CR>zz", { desc = "Next location list item (centered)" })
map("n", "<leader>j", "<cmd>lnext<CR>zz", { desc = "Previous location list item (centered)" })

-- Utils
map("n", "<C-s>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })
map("v", "<C-s>", [["zy:%s/<C-r>z/<C-r>z/gI<Left><Left><Left>]], { desc = "Substitute selected text" })

map("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

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
map("i", "?", "?<c-g>u", { desc = "Undo breakpoint after question mark" })
map("i", "!", "!<c-g>u", { desc = "Undo breakpoint after exclamation mark" })
map("i", ";", ";<c-g>u", { desc = "Undo breakpoint after semicolon" })

-- better indenting
map("v", "<", "<gv", { desc = "Indent left (preserve selection)" })
map("v", ">", ">gv", { desc = "Indent right (preserve selection)" })

-- commenting
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })

-- Copying for AI
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Copy relative path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Copy full path", silent = true })
map("n", "<leader>yl", function()
    local file_path = vim.fn.expand('%:~:.')
    local line_num = vim.fn.line('.')
    local reference = file_path .. ':' .. line_num
    vim.fn.setreg('+', reference)
    print('Copied: ' .. reference)
end, { desc = "Copy line reference (file:line)", silent = false })

map("n", "<leader>ym", function()
    local ts_utils = require('nvim-treesitter.ts_utils')
    local file_path = vim.fn.expand('%:~:.')

    -- Get current node and find parent function
    local current_node = ts_utils.get_node_at_cursor()
    if not current_node then
        print("No treesitter node found")
        return
    end

    -- Function node types for different languages
    local function_types = {
        'function_declaration',
        'function_definition',
        'method_declaration',
        'method_definition',
        'function_item',       -- Rust
        'arrow_function',      -- JavaScript
        'function_expression', -- JavaScript
        'local_function',      -- Lua
    }

    -- Walk up the tree to find a function node
    local function_node = current_node
    while function_node do
        local node_type = function_node:type()
        for _, func_type in ipairs(function_types) do
            if node_type == func_type then
                local start_row = function_node:start()
                local reference = file_path .. ':' .. (start_row + 1) -- Convert 0-based to 1-based
                vim.fn.setreg('+', reference)
                print('Copied: ' .. reference)
                return
            end
        end
        function_node = function_node:parent()
    end

    -- Fallback to current line if no function found
    local current_line = vim.fn.line('.')
    local reference = file_path .. ':' .. current_line
    vim.fn.setreg('+', reference)
    print('Copied (fallback): ' .. reference)
end, { desc = "Copy method reference (file:line)", silent = false })

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

map('n', '<leader>cs', function()
    require('config.themes').select_theme()
end, { desc = 'Telescope theme selector (live preview)' })

map("n", "<leader>so", function()
    vim.cmd("so")
end, { desc = 'Reload current file' })


-- Comments
-- if vim.env.TMUX ~= nil then
-- 	api.nvim_set_keymap("n", "<C-_>", "gtc", { noremap = false })
-- 	api.nvim_set_keymap("v", "<C-_>", "goc", { noremap = false })
-- else
-- 	api.nvim_set_keymap("n", "<C-/>", "gtc", { noremap = false })
-- 	api.nvim_set_keymap("v", "<C-/>", "goc", { noremap = false })
-- end
