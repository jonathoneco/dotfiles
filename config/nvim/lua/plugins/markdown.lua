return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
        ft = { 'markdown', 'quarto', 'rmd' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
        config = function()
            require('render-markdown').setup({
                completions = { lsp = { enabled = true } },
            })
        end
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        dependencies = {
            -- Required.
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "notes",
                    path = "~/src/notes",
                },
            },
            ui = {
                enable = false
            },
            completion = {
                nvim_cmp = true,
                min_chars = 2,
            },
            mappings = {
                -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
                ["gf"] = {
                    action = function()
                        return require("obsidian").util.gf_passthrough()
                    end,
                    opts = { noremap = false, expr = true, buffer = true },
                },
                -- Toggle check-boxes.
                ["<leader>ch"] = {
                    action = function()
                        return require("obsidian").util.toggle_checkbox()
                    end,
                    opts = { buffer = true },
                },
                -- Smart action depending on context, either follow link or toggle checkbox.
                ["<cr>"] = {
                    action = function()
                        return require("obsidian").util.smart_action()
                    end,
                    opts = { buffer = true, expr = true },
                }
            },
            new_notes_location = "0-inbox",
        },
    }
}
