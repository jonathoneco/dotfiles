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
            legacy_commands = false,
        },
        config = function(_, opts)
            require("obsidian").setup(opts)
            
            -- Set up keymaps in the config function instead of deprecated mappings option
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function()
                    local map = vim.keymap.set
                    local buf = vim.api.nvim_get_current_buf()
                    
                    -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
                    map("n", "gf", function()
                        return require("obsidian").util.gf_passthrough()
                    end, { noremap = false, expr = true, buffer = buf })
                    
                    -- Toggle check-boxes.
                    map("n", "<leader>ch", function()
                        return require("obsidian").util.toggle_checkbox()
                    end, { buffer = buf })
                    
                    -- Smart action depending on context, either follow link or toggle checkbox.
                    map("n", "<cr>", function()
                        return require("obsidian").util.smart_action()
                    end, { buffer = buf, expr = true })
                end,
            })
        end,
    }
}
