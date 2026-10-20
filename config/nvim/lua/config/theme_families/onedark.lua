local M = {}
local native = require("config.theme_native")

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

function M.herdr(variant, spec)
    local p = require("onedark.colors")
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg, p.bg2))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = p.bg1, selection_bg = p.bg3,
        surface1 = p.bg2, surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = p.grey, overlay1 = p.light_grey, text = p.fg, subtext0 = p.light_grey,
        mauve = p.purple, green = p.green, yellow = p.yellow, red = p.red,
        blue = p.blue, teal = p.cyan, peach = p.orange,
    }
end

return M
