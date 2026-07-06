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
            "williamboman/mason.nvim",
            lazy = false,
            priority = 1000,
            build = ":MasonUpdate",
        },
        {
            "williamboman/mason-lspconfig.nvim",
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

        local ensure_installed = {
            "lua_ls",
            "rust_analyzer",
            "gopls",
            "templ",
            "tailwindcss",
            "pyright",
            "ts_ls",
            "jsonls",
            "yamlls",
            "html",
            "cssls",
            "bashls",
            "dockerls",
            "solidity_ls_nomicfoundation",
            "vimls",
            "marksman",
            "clangd",
            "texlab",
        }

        for _, server_name in ipairs(ensure_installed) do
            vim.lsp.config(server_name, {
                capabilities = capabilities,
            })
        end

        vim.lsp.config("lua_ls", {
            capabilities = capabilities,
            settings = {
                Lua = {
                    format = {
                        enable = true,
                        -- NOTE: the value should be STRING!!
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "2",
                        }
                    },
                }
            }
        })

        vim.lsp.config("tailwindcss", {
            capabilities = capabilities,
            filetypes = {
                "html",
                "css",
                "scss",
                "javascript",
                "javascriptreact",
                "typescriptreact",
                "vue",
                "svelte",
                "templ",
            },
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
            ensure_installed = ensure_installed,
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
