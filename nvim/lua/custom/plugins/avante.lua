return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false,
  opts = {
    provider = 'copilot',
    providers = {
      copilot = {
        -- copilot config happens via copilot.lua usually
        -- avante.nvim just assumes you have it configured and authed
      },
    },
    input = {
      provider = 'snacks',
      provider_opts = {
        title = 'Avante Input',
        icon = ' ',
      },
    },
    selector = {
      provider = 'mini_pick', -- or "fzf_lua", "telescope", etc
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_keymaps = false,
      auto_apply_diff_after_generation = false,
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
    'stevearc/dressing.nvim', -- optional
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
    { '<leader>ca', '<cmd>AvanteToggle<cr>', desc = 'Avante: Toggle sidebar' },
    { '<leader>cr', '<cmd>AvanteRefresh<cr>', desc = 'Avante: Refresh' },
    { '<leader>cf', '<cmd>AvanteFocus<cr>', desc = 'Avante: Focus sidebar' },
    { '<leader>c?', '<cmd>AvanteSwitchProvider<cr>', desc = 'Avante: Switch Provider' },
    { '<leader>ce', '<cmd>AvanteEdit<cr>', desc = 'Avante: Edit Selected Block' },
    { '<leader>cS', '<cmd>AvanteStop<cr>', desc = 'Avante: Stop Request' },
    { '<leader>ch', '<cmd>AvanteHistory<cr>', desc = 'Avante: Chat History' },
    { '<leader>cB', "<cmd>AvanteToggle<cr> | :lua require('avante').get().file_selector:add_all_buffers()<cr>", desc = 'Avante: Add All Buffers' },
  },
}
