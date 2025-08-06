return {
    { "folke/neoconf.nvim", cmd = "Neoconf" },
    "folke/neodev.nvim",
    {
        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = { signs = false },
        -- stylua: ignore
    },
    "eandrju/cellular-automaton.nvim",
    {
        "nvim-lua/plenary.nvim",
        name = "plenary"
    },

    {
        "lewis6991/gitsigns.nvim",
        lazy = false,
        config = function()
            require("gitsigns").setup()
        end
    },
    {
        "tpope/vim-fugitive",
        lazy = false,
    },

    {
        "RRethy/vim-illuminate",
        lazy = false,
        config = function()
            require("illuminate").configure({})
        end,
    },
    'nvim-tree/nvim-web-devicons',
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        lazy = false,
        opts = {},
    },

    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        opts = {},
    },
    {
        "windwp/nvim-ts-autotag",
        lazy = false,
    },
    "tpope/vim-sleuth",
    "vuciv/golf",
    { -- Collection of various small independent plugins/modules
        'echasnovski/mini.nvim',
        lazy = false,
        config = function()
            require('mini.ai').setup { n_lines = 500 }
            require('mini.icons').setup()
            require('mini.surround').setup()
        end,
    },
}
