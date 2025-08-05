local function augroup(name)
    return vim.api.nvim_create_augroup("local_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

function R(name)
    require("plenary.reload").reload_module(name)
end

-- LSP
autocmd("BufWritePre", {
	group = augroup("lsp_formatting_group"),
	callback = function()
		local efm = vim.lsp.get_clients({ name = "efm" })

		if vim.tbl_isempty(efm) then
			return
		end

		vim.lsp.buf.format({ name = "efm", async = true })
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
            vim.opt_local.spell = true
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
        vim.schedule(function()
            require("config.themes").load_last_theme()
        end)
    end,
})

autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- Disable comment on new line
    vim.opt.formatoptions:remove { "c", "r", "o" }
  end,
  group = general,
  desc = "Disable New Line Comment",
})
