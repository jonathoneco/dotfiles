return {
  {
    'jakewvincent/mkdnflow.nvim',
    ft = 'markdown',
    config = function()
      require('mkdnflow').setup {
        modules = {
          bib = false,
          buffers = true,
          conceal = true,
          cursor = true,
          folds = true,
          links = true,
          lists = true,
          maps = true,
          paths = true,
          tables = true,
        },
        filetypes = { md = true, markdown = true },
        create_dirs = true,
        perspective = {
          priority = 'root',
          root_tell = false,
          nvim_wd_heel = false,
          update = false,
        },
        links = {
          style = 'markdown',
          name_is_source = false,
          conceal = true,
          context = 0,
          implicit_extension = nil,
          transform_implicit = false,
          transform_explicit = function(text)
            return text:lower():gsub(' ', '-')
          end,
        },
        lists = {
          indent = 2,
          unordered = { '-', '*', '+' },
          ordered = { '1.', 'a)' },
        },
        to_do = {
          symbols = { ' ', '~', 'x' },
          update_parents = true,
          not_started = ' ',
          in_progress = '~',
          complete = 'x',
        },
        tables = {
          trim_whitespace = true,
          format_on_move = true,
          auto_extend_rows = false,
        },
      }
    end,
  },

  {
    'lukas-reineke/headlines.nvim',
    ft = { 'markdown', 'norg', 'org' },
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
  },

  {
    'dhruvasagar/vim-table-mode',
    ft = 'markdown',
  },
}
