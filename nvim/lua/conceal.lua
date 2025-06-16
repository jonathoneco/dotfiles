vim.api.nvim_create_autocmd('FileType', {
  pattern = '*', -- or restrict to specific types like 'lua', 'python', etc.
  callback = function()
    -- Make sure conceal is enabled in this buffer
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = 'nc'

    -- Enable syntax highlighting if it isn't already
    if vim.fn.exists 'syntax_on' == 0 then
      vim.cmd 'syntax enable'
    end

    -- Apply the conceal rules
    vim.cmd [[
      syntax match NotEqual /!=/ conceal cchar=≠
      syntax match GreaterEqual />=/ conceal cchar=≥
      syntax match LessEqual /<=/ conceal cchar=≤
    ]]
  end,
})
