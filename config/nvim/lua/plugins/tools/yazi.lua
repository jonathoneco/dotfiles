---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "\\",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>se",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    -- {
    --   "<c-up>",
    --   "<cmd>Yazi toggle<cr>",
    --   desc = "Resume the last yazi session",
    -- },
  },
  ---@type YaziConfig | {}
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
    yazi_floating_window_border = "rounded",
    log_level = vim.log.levels.OFF,
    -- Use wrapper script when in tmux to avoid terminal response timeout
    open_cmd = vim.env.TMUX and "yazi-tmux" or "yazi",
  },
  -- 👇 if you use `open_for_directories=true`, this is recommended
  init = function()
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    -- vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
}
