return {
    { "catppuccin/nvim",       name = "catppuccin", lazy = false,   priority = 1000 },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    { "rebelot/kanagawa.nvim", lazy = false,        priority = 1000 },
    { "rose-pine/neovim",      name = "rose-pine",  lazy = false,   priority = 1000 },
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("onedark").setup({
                style = "darker",
            })
        end,
    },
    { "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
    {
        'sainnhe/gruvbox-material',
        lazy = false,
        priority = 1000,
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.gruvbox_material_enable_italic = true
            vim.cmd.colorscheme('gruvbox-material')
        end
    },
    {
        'sainnhe/everforest',
        lazy = false,
        priority = 1000,
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.everforest_enable_italic = true
        end
    },
}
