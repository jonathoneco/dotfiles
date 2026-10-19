return {
    "neovim/nvim-lspconfig",
    lazy = false,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "stevearc/conform.nvim",
            lazy = false,
            event = { "BufReadPre", "BufNewFile" },
        },
        {
            "mason-org/mason.nvim",
            lazy = false,
            priority = 1000,
            build = ":MasonUpdate",
        },
        {
            "mason-org/mason-lspconfig.nvim",
            lazy = false,
        },
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                markdown = { "prettier" },
            }
        })

        -- Load custom snippets
        require("config.snippets")

        -- Load VS Code style snippets from friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        vim.lsp.config("*", { capabilities = capabilities })
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    format = {
                        enable = true,
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "2",
                        },
                    },
                },
            },
        })
        vim.lsp.config("zls", {
            root_markers = { ".git", "build.zig", "zls.json" },
            settings = {
                zls = {
                    enable_inlay_hints = true,
                    enable_snippets = true,
                    warn_style = true,
                },
            },
        })
        vim.g.zig_fmt_parse_errors = 0
        vim.g.zig_fmt_autosave = 0

        vim.lsp.config("marksman", {
            root_markers = {},
            root_dir = function(bufnr, on_dir)
                local root = vim.fs.root(bufnr, { ".marksman.toml", ".git" })
                if root == vim.uv.os_homedir() and not vim.uv.fs_stat(root .. "/.marksman.toml") then
                    root = nil
                end
                on_dir(root)
            end,
        })

        vim.lsp.config("tailwindcss", {
            filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "templ" },
            settings = {
                tailwindCSS = {
                    experimental = {
                        classRegex = {
                            "tw`([^`]*)",
                            "tw=\"([^\"]*)",
                            "tw={\"([^\"}]*)",
                            "tw\\.\\w+`([^`]*)",
                            "tw\\(.*?\\)`([^`]*)",
                        },
                    },
                },
            },
        })

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls", "rust_analyzer", "gopls", "templ", "tailwindcss",
                "pyright", "ts_ls", "jsonls", "yamlls", "html", "cssls",
                "bashls", "dockerls", "solidity_ls_nomicfoundation", "vimls",
                "marksman", "clangd", "texlab",
            },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            -- preselect = cmp.PreselectMode.None,
            sorting = {
                priority_weight = 2,
                comparators = {
                    cmp.config.compare.exact,
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                }
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                -- ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = {
                -- { name = 'luasnip',  priority = 1000, group_index = 1 },
                -- { name = 'nvim_lsp', priority = 100,  group_index = 2 },
                -- { name = 'buffer',   priority = 50,   group_index = 3 },
                { name = 'nvim_lsp' },
                { name = 'buffer' },
                { name = 'luasnip' },
                { name = 'path' },
            }
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
