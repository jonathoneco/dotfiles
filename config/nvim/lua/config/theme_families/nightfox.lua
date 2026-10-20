local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("nightfox").setup({
        options = { transparent = true, terminal_colors = true },
        groups = { all = { NormalFloat = { bg = "NONE" }, FloatBorder = { bg = "NONE" } } },
    })
    vim.cmd.colorscheme(variant.native_options.style)
end

function M.palette()
    local p = require("nightfox.spec").load(vim.g.colors_name)
    return {
        background = p.bg1, foreground = p.fg1,
        cursor = p.fg1, cursor_text = p.bg1,
        selection_background = p.sel0, selection_foreground = p.fg1,
    }
end

return M
