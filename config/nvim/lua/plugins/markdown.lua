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
                latex = { enabled = true },
                heading = {
                    border = true,
                },
                code = {
                    language_border = ' ',
                    language_left = '',
                    language_right = '',
                },
                -- bullet = { left_pad = 1 },
                checkbox = {
                    unchecked = {
                        -- Replaces '[ ]' of 'task_list_marker_unchecked'.
                        icon = '󰄱 ',
                        -- Highlight for the unchecked icon.
                        highlight = 'RenderMarkdownUnchecked',
                        -- Highlight for item associated with unchecked checkbox.
                        scope_highlight = nil,
                    },
                    checked = {
                        -- Replaces '[x]' of 'task_list_marker_checked'.
                        icon = ' ',
                        -- Highlight for the checked icon.
                        highlight = 'RenderMarkdownChecked',
                        -- Highlight for item associated with checked checkbox.
                        scope_highlight = '@markup.strikethrough',
                    },
                    custom = {
                        progress = { raw = '[~]', rendered = '󰰱 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                        warning = { raw = '[!]', rendered = ' ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                        forward = { raw = '[>]', rendered = ' ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                    }
                },
                quote = { repeat_linebreak = true },
                win_options = {
                    showbreak = {
                        default = '',
                        rendered = '  ',
                    },
                    breakindent = {
                        default = false,
                        rendered = true,
                    },
                    breakindentopt = {
                        default = '',
                        rendered = '',
                    },
                },
                pipe_table = { preset = 'round' },
                -- indent = {
                --     enabled = true,
                --     skip_heading = true,
                -- },
            })
        end
    },
    {
        "obsidian-nvim/obsidian.nvim",
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
                    path = "~/src/garden-log",
                },
            },
            ui = {
                enable = false
            },
            completion = {
                nvim_cmp = true,
                min_chars = 2,
            },
            disable_frontmatter = true,
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
        },
    }
}
