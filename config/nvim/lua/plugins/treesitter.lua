local parsers = {
    "vim", "vimdoc", "regex", "rust", "markdown", "markdown_inline", "json", "jsdoc",
    "javascript", "typescript", "yaml", "html", "css", "bash",
    "lua", "dockerfile", "solidity", "gitignore", "python",
    "vue", "svelte", "toml", "go", "c", "latex", "bibtex", "sql", "templ",
}

local config = function()
    local ts = require("nvim-treesitter")

    local install_dir = vim.fn.stdpath('data') .. '/site'

    -- Must prepend to runtimepath for parser compatibility
    vim.opt.runtimepath:prepend(install_dir)

    ts.setup({
        install_dir = install_dir,
    })

    -- Install missing parsers on startup
    local installed = ts.get_installed()
    local to_install = vim.tbl_filter(function(p)
        return not vim.list_contains(installed, p)
    end, parsers)

    if #to_install > 0 then
        ts.install(to_install)
    end

    -- Enable treesitter highlighting for filetypes (new API)
    vim.api.nvim_create_autocmd('FileType', {
        pattern = parsers,
        callback = function(args)
            -- Disable for large files
            local max_filesize = 100 * 1024 -- 100 KB
            local ok_stat, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
            if ok_stat and stats and stats.size > max_filesize then
                vim.notify(
                    "File larger than 100KB, treesitter disabled",
                    vim.log.levels.WARN
                )
                return
            end

            -- Don't enable for html
            if vim.bo[args.buf].filetype == "html" then
                return
            end

            vim.treesitter.start(args.buf)
        end,
    })

    -- Enable treesitter indent
    vim.api.nvim_create_autocmd('FileType', {
        pattern = parsers,
        callback = function(args)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })

    -- Custom parser for templ - register the filetype
    vim.treesitter.language.register("templ", "templ")
end
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false,
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        },
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
