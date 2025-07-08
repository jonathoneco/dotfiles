require 'options'
require 'keymaps'
require 'lazy-bootstrap'
require 'lazy-plugins'

local augroup = vim.api.nvim_create_augroup
local general_group = augroup('GeneralGroup', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
  require('plenary.reload').reload_module(name)
end

vim.filetype.add {
  extension = {
    templ = 'templ',
  },
}

-- Temporarily highlights yanked text
autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank {
      higroup = 'IncSearch',
      timeout = 40,
    }
  end,
})

-- Prunes whitespace at the end of lines
autocmd({ 'BufWritePre' }, {
  group = general_group,
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

-- LSP key bindings
autocmd('LspAttach', {
  group = general_group,
  callback = function(e)
    vim.keymap.set('n', 'gd', function()
      vim.lsp.buf.definition()
    end, { buffer = e.buf, desc = 'Go to Definition' })
    vim.keymap.set('n', 'gD', function()
      vim.lsp.buf.declaration()
    end, { buffer = e.buf, desc = 'Go to Declaration' })
    vim.keymap.set('n', 'gi', function()
      vim.lsp.buf.implementation()
    end, { buffer = e.buf, desc = 'Go to Implementation' })
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover()
    end, { buffer = e.buf, desc = 'Hover Documentation' })
    vim.keymap.set('n', '<leader>vws', function()
      vim.lsp.buf.workspace_symbol()
    end, { buffer = e.buf, desc = 'Workspace Symbols' })
    vim.keymap.set('n', '<leader>vd', function()
      vim.diagnostic.open_float()
    end, { buffer = e.buf, desc = 'Open Diagnostic Float' })
    vim.keymap.set('n', '<leader>vca', function()
      vim.lsp.buf.code_action()
    end, { buffer = e.buf, desc = 'Code Actions' })
    vim.keymap.set('n', '<leader>vrr', function()
      vim.lsp.buf.references()
    end, { buffer = e.buf, desc = 'Find References' })
    vim.keymap.set('n', '<leader>vrn', function()
      vim.lsp.buf.rename()
    end, { buffer = e.buf, desc = 'Rename Symbol' })
    vim.keymap.set('i', '<C-h>', function()
      vim.lsp.buf.signature_help()
    end, { buffer = e.buf, desc = 'Signature Help' })
    vim.keymap.set('n', '[d', function()
      vim.diagnostic.goto_next()
    end, { buffer = e.buf, desc = 'Next Diagnostic' })
    vim.keymap.set('n', ']d', function()
      vim.diagnostic.goto_prev()
    end, { buffer = e.buf, desc = 'Previous Diagnostic' })
  end,
})

-- Prevents 'o' motions from extending comments
autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove 'o'
  end,
})

autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- optional: wraps at word boundaries
    vim.keymap.set('n', 'j', 'gj', { buffer = true })
    vim.keymap.set('n', 'k', 'gk', { buffer = true })
  end,
})

require('custom.themes').load_last_theme()
