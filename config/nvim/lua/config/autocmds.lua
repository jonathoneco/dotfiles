local function augroup(name)
    return vim.api.nvim_create_augroup("local_" .. name, { clear = true })
end
local ThePrimeagenGroup = augroup('ThePrimeagen')

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank')

function R(name)
    require("plenary.reload").reload_module(name)
end

-- LSP

autocmd('LspAttach', {
    group = augroup('lsp_attach'),
    callback = function(e)
        vim.keymap.set('n', 'gd', function()
            vim.lsp.buf.definition()
        end, { buffer = e.buf, desc = 'Go to Definition' })
        vim.keymap.set('n', 'gD', function()
            vim.lsp.buf.declaration()
        end, { buffer = e.buf, desc = 'Go to Declaration' })
        vim.keymap.set('n', 'gi', function()
            vim.lsp.buf.implementation()
        end, { buffer = e.buf, desc = 'Go to Implementation' })
        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover()
        end, { buffer = e.buf, desc = 'Hover Documentation' })
        vim.keymap.set('n', '<leader>vws', function()
            vim.lsp.buf.workspace_symbol()
        end, { buffer = e.buf, desc = 'Workspace Symbols' })
        vim.keymap.set('n', '<leader>vd', function()
            vim.diagnostic.open_float()
        end, { buffer = e.buf, desc = 'Open Diagnostic Float' })
        vim.keymap.set('n', '<leader>vca', function()
            vim.lsp.buf.code_action()
        end, { buffer = e.buf, desc = 'Code Actions' })
        vim.keymap.set('n', '<leader>vrr', function()
            vim.lsp.buf.references()
        end, { buffer = e.buf, desc = 'Find References' })
        vim.keymap.set('n', '<leader>vrn', function()
            vim.lsp.buf.rename()
        end, { buffer = e.buf, desc = 'Rename Symbol' })
        vim.keymap.set('i', '<C-h>', function()
            vim.lsp.buf.signature_help()
        end, { buffer = e.buf, desc = 'Signature Help' })
        vim.keymap.set('n', '[d', function()
            vim.diagnostic.goto_next()
        end, { buffer = e.buf, desc = 'Next Diagnostic' })
        vim.keymap.set('n', ']d', function()
            vim.diagnostic.goto_prev()
        end, { buffer = e.buf, desc = 'Previous Diagnostic' })
    end,
})

-- FileType
-- Wrap and check for spell in text filetypes
autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.keymap.set('n', 'j', 'gj', { buffer = true })
        vim.keymap.set('n', 'k', 'gk', { buffer = true })
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

-- Prunes whitespace at the end of lines
autocmd({ 'BufWritePre' }, {
    group = general_group,
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
