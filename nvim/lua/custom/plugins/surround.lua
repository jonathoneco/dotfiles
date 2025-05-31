return {
  'kylechui/nvim-surround',
  version = '*', -- Use for stability
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup {
      -- Add custom surroundings here
      surrounds = {
        -- e.g., tag surrounds with smart input
        ['t'] = {
          add = function()
            local tag = vim.fn.input '<tag>: '
            return { { '<' .. tag .. '>' }, { '</' .. tag .. '>' } }
          end,
          find = function()
            return require('nvim-surround.config').get_selection { pattern = '[%w%-]+', char = 't' }
          end,
          delete = '^(<[%w%-]+>)().-(</[%w%-]+>)()$',
        },
      },
    }
  end,
}
