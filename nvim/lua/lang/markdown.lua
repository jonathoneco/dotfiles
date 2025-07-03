return {
  {
    'lukas-reineke/headlines.nvim',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    ft = { 'markdown' },
    config = true,
  },

  {
    'preservim/vim-markdown',
    ft = { 'markdown' }
  },

  {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    build = 'cd app && npm install',
    config = function()
      vim.g.mkdp_auto_start = 1
    end,
  },

  {
    'jakewvincent/mkdnflow.nvim',
    ft = 'markdown',
    config = function()
      require('mkdnflow').setup {}
    end,
  },
}

