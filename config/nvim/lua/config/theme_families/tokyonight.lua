local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("tokyonight").setup({
        style = variant.native_options.style,
        transparent = true,
        terminal_colors = true,
        styles = { sidebars = "transparent", floats = "transparent" },
    })
    vim.cmd.colorscheme("tokyonight-" .. variant.native_options.style)
end

function M.palette()
    local p = require("tokyonight.colors").setup()
    return {
        background = p.bg, foreground = p.fg,
        cursor = p.fg, cursor_text = p.bg,
        selection_background = p.bg_visual, selection_foreground = p.fg,
    }
end

return M
