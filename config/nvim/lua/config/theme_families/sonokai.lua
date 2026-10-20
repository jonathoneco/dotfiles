local M = {}
local native = require("config.theme_native")

local function palette()
    return vim.fn["sonokai#get_palette"](vim.g.sonokai_style, vim.empty_dict())
end

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.g.sonokai_style = variant.native_options.style
    vim.g.sonokai_transparent_background = 2
    vim.g.sonokai_float_style = "blend"
    vim.g.sonokai_better_performance = 0
    vim.g.sonokai_disable_terminal_colors = 0
    vim.g.sonokai_colors_override = vim.empty_dict()
    vim.cmd.colorscheme("sonokai")
end

function M.palette()
    local p = palette()
    local cursor = native.pair("Cursor", p.fg[1], p.bg0[1])
    return {
        background = p.bg0[1], foreground = p.fg[1],
        cursor = cursor.bg, cursor_text = cursor.fg,
        selection_background = native.color("Visual", "bg"), selection_foreground = p.fg[1],
    }
end

function M.herdr(variant, spec)
    local p = palette()
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg[1], p.bg2[1]))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = native.color("Visual", "bg"), surface1 = p.bg2[1],
        surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = p.grey[1], overlay1 = p.grey[1], text = p.fg[1], subtext0 = p.grey[1],
        mauve = p.purple[1], green = native.color("DiagnosticOk", "fg"),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"),
        peach = p.orange[1],
    }
end

return M
