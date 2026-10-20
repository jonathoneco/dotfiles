local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("onedark").setup({
        style = variant.native_options.style,
        transparent = true,
        term_colors = true,
        highlights = { NormalFloat = { bg = "NONE" } },
    })
    vim.cmd.colorscheme("onedark")
end

function M.palette()
    local p = require("onedark.colors")
    return {
        background = p.bg0, foreground = p.fg,
        cursor = p.fg, cursor_text = p.bg0,
        selection_background = p.bg3, selection_foreground = p.fg,
    }
end

return M
