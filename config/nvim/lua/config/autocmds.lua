local function augroup(name)
    return vim.api.nvim_create_augroup("local_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.api.nvim_create_user_command("TypeScriptOrganizeImports", function()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.fn.expand("%:p") },
    }
    vim.lsp.buf.execute_command(params)
end, { desc = "Organize TypeScript imports" })

autocmd("LspAttach", {
    group = augroup("lsp_keymaps"),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- LSP keymaps using built-in functions
        vim.keymap.set("n", "gk", function() vim.lsp.buf.hover() end,
            vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end,
            vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gS", function()
            vim.cmd("vsplit")
            vim.lsp.buf.definition()
        end, vim.tbl_extend("force", opts, { desc = "Go to definition in split" }))
        vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end,
            vim.tbl_extend("force", opts, { desc = "Find implementations" }))
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end,
            vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        vim.keymap.set("n", '<leader>vws', function() vim.lsp.buf.workspace_symbol() end,
            vim.tbl_extend("force", opts, { desc = "Workspace symbol search" }))
        vim.keymap.set("n", '<leader>ss', function()
            require('telescope.builtin').lsp_dynamic_workspace_symbols()
        end, vim.tbl_extend("force", opts, { desc = "Workspace symbol search (fuzzy)" }))
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end,
            vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))
        vim.keymap.set("n", "<leader>vD", function() vim.diagnostic.setqflist() end,
            vim.tbl_extend("force", opts, { desc = "Show workspace diagnostics" }))
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end,
            vim.tbl_extend("force", opts, { desc = "Code actions" }))
        vim.keymap.set("n", "<leader>vrr", function()
            vim.lsp.buf.references()
        end, vim.tbl_extend("force", opts, { desc = "Find references" }))
        vim.keymap.set("n", "<leader>vq", function()
            if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
                vim.cmd("cclose")
            else
                vim.cmd("copen")
            end
        end, vim.tbl_extend("force", opts, { desc = "Toggle quickfix list" }))
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end,
            vim.tbl_extend("force", opts, { desc = "Smart rename" }))
        vim.keymap.set("n", "<M-h>", function() vim.lsp.buf.signature_help() end,
            vim.tbl_extend("force", opts, { desc = "Signature help" }))
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end,
            vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end,
            vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

        if client.name == "pyright" then
            vim.keymap.set("n", "<leader>oi", function() vim.cmd("PyrightOrganizeImports") end,
                vim.tbl_extend("force", opts, { desc = "Organize imports" }))
            vim.keymap.set("n", "<leader>db", function() vim.cmd("DapToggleBreakpoint") end,
                vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
            vim.keymap.set("n", "<leader>dr", function() vim.cmd("DapContinue") end,
                vim.tbl_extend("force", opts, { desc = "Continue/invoke debugger" }))
            vim.keymap.set("n", "<leader>dt", function() require('dap-python').test_method() end,
                vim.tbl_extend("force", opts, { desc = "Run tests" }))
        end

        if client.name == "ts_ls" then
            vim.keymap.set("n", "<leader>oi", function() vim.cmd("TypeScriptOrganizeImports") end,
                vim.tbl_extend("force", opts, { desc = "Organize imports" }))
        end
    end,
})

-- Format on save - prefer LSP, fallback to conform
autocmd("BufWritePre", {
    group = augroup("format_on_save"),
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Try LSP formatting first
        local lsp_clients = vim.lsp.get_clients({ bufnr = bufnr })
        local has_lsp_formatter = false

        for _, client in pairs(lsp_clients) do
            if client.supports_method("textDocument/formatting") then
                has_lsp_formatter = true
                break
            end
        end

        if has_lsp_formatter then
            vim.lsp.buf.format({ bufnr = bufnr })
        else
            -- Fallback to conform if available
            local ok, conform = pcall(require, "conform")
            if ok then
                conform.format({ bufnr = bufnr })
            end
        end
    end,
})

-- FileType
-- Wrap and check for spell in text filetypes
autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.schedule(function()
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.breakindent = true
            -- vim.opt_local.spell = true
            vim.keymap.set('n', 'j', 'gj', { buffer = true, desc = "Move down by display line" })
            vim.keymap.set('n', 'k', 'gk', { buffer = true, desc = "Move up by display line" })
        end)
    end,
})

-- Prevent IndentLine from hiding ``` in markdown files
autocmd({ "FileType" }, {
    group = augroup("editing"),
    pattern = { "markdown" },
    callback = function()
        vim.g["indentLine_enabled"] = 0
        vim.g["markdown_syntax_conceal"] = 0
    end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})


-- Temporarily highlights yanked text
autocmd('TextYankPost', {
    group = augroup("highlight_yank"),
    pattern = '*',
    callback = function()
        vim.highlight.on_yank {
            higroup = 'IncSearch',
            timeout = 100,
        }
    end,
})

-- Prunes whitespace at the end of lines
autocmd({ 'BufWritePre' }, {
    group = augroup("prune_eol_whitespace"),
    pattern = '*',
    command = [[%s/\s\+$//e]],
})



-- Close different buffers with `q`
autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

-- Conceal settings
autocmd('FileType', {
    pattern = '*', -- or restrict to specific types like 'lua', 'python', etc.
    callback = function()
        -- Make sure conceal is enabled in this buffer
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = 'nc'

        -- Enable syntax highlighting if it isn't already
        if vim.fn.exists 'syntax_on' == 0 then
            vim.cmd 'syntax enable'
        end

        -- Apply the conceal rules
        vim.cmd [[
      syntax match NotEqual /!=/ conceal cchar=≠
      syntax match GreaterEqual />=/ conceal cchar=≥
      syntax match LessEqual /<=/ conceal cchar=≤
    ]]
    end,
})

-- Run resize methods when window size is changes
autocmd("VimResized", {
    group = augroup("general"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()

        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- Load saved theme after plugins are loaded
autocmd("VimEnter", {
    group = augroup("load_last_theme"),
    callback = function()
        require("config.themes").load_last_theme()
    end,
})

autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
    end,
    group = augroup("markdown_indent"),
    desc = "Set markdown indentation to 2 spaces",
})

autocmd("FileType", {
    pattern = "*",
    callback = function()
        -- Disable comment on new line
        vim.opt.formatoptions:remove { "c", "r", "o" }
    end,
    group = augroup("general"),
    desc = "Disable New Line Comment",
})
