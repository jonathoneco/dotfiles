-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Move selected lines in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Centers various jumping motions
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Clipboard management
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste over without yanking' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })

vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete without yanking' })

-- Tmux passthrough
vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>', { desc = 'Open tmux sessionizer' })
vim.keymap.set('n', '<leader>f', function()
  require('conform').format { bufnr = 0 }
end, { desc = 'Format current buffer' })

vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz', { desc = 'Previous quickfix list item' })
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz', { desc = 'Next quickfix list item' })
vim.keymap.set('n', '<leader>k', '<cmd>lprev<CR>zz', { desc = 'Previous location list item' })
vim.keymap.set('n', '<leader>j', '<cmd>lnext<CR>zz', { desc = 'Next location list item' })

vim.keymap.set('n', '<C-s>', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Substitute word under cursor globally' })

vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'Make file executable' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Auto Indent Paragraph
vim.keymap.set('n', '=ap', "ma=ap'a")

-- Go Mappings
vim.keymap.set('n', '<leader>ee', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>')

vim.keymap.set('n', '<leader>ea', 'oassert.NoError(err, "")<Esc>F";a')

vim.keymap.set('n', '<leader>ef', 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj')

vim.keymap.set('n', '<leader>el', 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i')

-- Misc
vim.keymap.set('i', '<C-c>', '<Esc>')
vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('n', '<leader><leader>', function()
  vim.cmd 'so'
end)

vim.keymap.set('n', '<leader>cs', function()
  require('custom.themes').select_theme_telescope()
end, { desc = 'Telescope theme selector (live preview)' })

vim.keymap.set('n', '<leader>ca', function()
    require("cellular-automaton").start_animation("make_it_rain")
end, { desc = 'Make it rain 🌧️' })


-- vim: ts=2 sts=2 sw=2 et
