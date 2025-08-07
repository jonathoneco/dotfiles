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
                        scope_highlight = nil,
                    },
                    custom = {
                        progress = { raw = '[~]', rendered = '󰰱 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                        warning = { raw = '[!]', rendered = ' ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                        forward = { raw = '[>]', rendered = ' ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                    }
                },
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
            new_notes_location = "0 Inbox",
            -- Generate unique UUID-based IDs
            note_id_func = function(title)
                local suffix = ""
                if title ~= nil then
                    -- Create URL-safe slug from title
                    suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                else
                    -- Random suffix if no title
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                end
                return tostring(os.time()) .. "-" .. suffix
            end,

            -- Create structured frontmatter
            note_frontmatter_func = function(note)
                -- Generate semantic ID from path structure
                local buf_path = vim.api.nvim_buf_get_name(0)
                local workspace_path = note.client.current_workspace.path:tostring()

                -- Get relative path and clean it
                local rel_path = buf_path:gsub("^" .. workspace_path .. "/", "")
                local path_parts = vim.split(vim.fn.fnamemodify(rel_path, ":h"), "/")

                -- Clean path parts (remove numbers and special chars)
                local clean_parts = {}
                for _, part in ipairs(path_parts) do
                    if part ~= "." then
                        local clean = part:gsub("^%d+%s*", ""):gsub("[^%w]", "-"):lower()
                        if clean ~= "" then
                            table.insert(clean_parts, clean)
                        end
                    end
                end

                -- Add title to path
                local title_slug = ""
                if note.title then
                    title_slug = note.title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                end

                -- Create semantic ID
                local semantic_id
                if #clean_parts > 0 then
                    table.insert(clean_parts, title_slug)
                    semantic_id = table.concat(clean_parts, ".")
                else
                    semantic_id = title_slug
                end

                -- Build aliases
                local aliases = {}
                if note.title then
                    table.insert(aliases, note.title) -- Note name
                end
                if semantic_id ~= "" then
                    table.insert(aliases, semantic_id) -- Semantic ID
                end

                return {
                    id = note.id,              -- Unique ID
                    semantic_id = semantic_id, -- Semantic ID
                    aliases = aliases,         -- Note name + semantic ID
                    tags = note.tags or {},    -- Tags (empty by default)
                    created = os.date("%Y-%m-%d"),
                    modified = os.date("%Y-%m-%d"),
                }
            end,

            -- Optional: Disable frontmatter management if you want full control
            disable_frontmatter = false,

        },
    }
}
