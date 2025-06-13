return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false,
  opts = {
    provider = 'copilot',
    providers = {
      copilot = {},
    },
    input = {
      provider = 'snacks',
      provider_opts = {
        title = 'Avante Input',
        icon = ' ',
      },
    },
    selector = {
      provider = 'mini_pick',
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_keymaps = false,
      auto_apply_diff_after_generation = false,
    },
    hints = {
      enabled = false,
    },
  },
  build = 'make',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'echasnovski/mini.pick',
    'hrsh7th/nvim-cmp',
    'zbirenbaum/copilot.lua',
    'folke/snacks.nvim',
    'stevearc/dressing.nvim',
    'nvim-tree/nvim-web-devicons',
    {
      'HakonHarnes/img-clip.nvim',
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
  keys = {
    { '<leader>ca', '<cmd>AvanteToggle<cr>', mode = 'n', desc = 'Avante: Toggle Sidebar' },
    { '<leader>cr', '<cmd>AvanteRefresh<cr>', mode = 'n', desc = 'Avante: Refresh' },
    { '<leader>cf', '<cmd>AvanteFocus<cr>', mode = 'n', desc = 'Avante: Focus Sidebar' },
    { '<leader>c?', '<cmd>AvanteSwitchProvider<cr>', mode = 'n', desc = 'Avante: Switch Provider' },
    { '<leader>ce', '<cmd>AvanteEdit<cr>', mode = 'n', desc = 'Avante: Edit Selected Block' },
    { '<leader>cS', '<cmd>AvanteStop<cr>', mode = 'n', desc = 'Avante: Stop Request' },
    { '<leader>ch', '<cmd>AvanteHistory<cr>', mode = 'n', desc = 'Avante: Chat History' },
    {
      '<leader>cB',
      "<cmd>AvanteToggle<cr> | :lua require('avante').get().file_selector:add_all_buffers()<cr>",
      mode = 'n',
      desc = 'Avante: Add All Buffers',
    },
    {
      '<leader>ca',
      function()
        require('avante.api').ask { range = true }
      end,
      mode = 'x',
      desc = 'Avante: Ask about selection',
    },
    {
      '<leader>ce',
      ":'<,'>AvanteEdit<CR>",
      mode = 'x',
      desc = 'Avante: Edit selected block',
    },
  },
  config = function(_, opts)
    require('avante').setup(opts)
  end,
}
