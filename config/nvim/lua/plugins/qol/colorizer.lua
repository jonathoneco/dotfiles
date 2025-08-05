return {
  "catgoose/nvim-colorizer.lua",
  event = "VeryLazy", -- Load lazily, but not on BufReadPre to avoid auto-enable
  opts = {
    filetypes = {}, -- still define where it works
    user_default_options = {
      RGB = true,
      RGBA = true,
      RRGGBB = true,
      RRGGBBAA = false,
      AARRGGBB = true,
    }
  },
  config = function(_, opts)
    -- Setup the plugin, but do not call Colorizer.attach_to_buffer
    require("colorizer").setup(opts)

    -- Optional: define a global keymap to toggle
    vim.keymap.set("n", "<leader>cc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colorizer" })
  end,
}

