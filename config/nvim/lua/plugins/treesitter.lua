local config = function()
    require("nvim-treesitter.configs").setup({
        build = ":TSUpdate",
        indent = {
            enable = true,
        },
        autotag = {
            enable = true,
        },
        event = {
            "BufReadPre",
            "BufNewFile",
        },
        ensure_installed = {
            "vim",
            "vimdoc",
            "regex",
            "rust",
            "markdown",
            "json",
            "jsdoc",
            "javascript",
            "typescript",
            "yaml",
            "html",
            "css",
            "markdown",
            "bash",
            "lua",
            "dockerfile",
            "solidity",
            "gitignore",
            "python",
            "vue",
            "svelte",
            "toml",
            "go",
            "c",
        },
        sync_install = true,
        auto_install = true,
        highlight = {
            enable = true,
            disable = function(lang, buf)
                if lang == "html" then
                    print("disabled")
                    return true
                end

                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    vim.notify(
                        "File larger than 100KB treesitter disabled for performance",
                        vim.log.levels.WARN,
                        { title = "Treesitter" }
                    )
                    return true
                end
            end,
            additional_vim_regex_highlighting = { "markdown" },
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                node_incremental = "<CR>",
                scope_incremental = false,
                node_decremental = "<BS>",
            },
        },
    })
    local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    treesitter_parser_config.templ = {
        install_info = {
            url = "https://github.com/vrischmann/tree-sitter-templ.git",
            files = { "src/parser.c", "src/scanner.c" },
            branch = "master",
        },
    }

    vim.treesitter.language.register("templ", "templ")
end
return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        config = config,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        after = "nvim-treesitter",
        config = function()
            require 'treesitter-context'.setup {
                enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false,      -- Enable multiwindow support.
                max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }
        end
    }
}
