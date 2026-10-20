local M = {}
local native = require("config.theme_native")

local function palette()
    return vim.fn["edge#get_palette"](vim.g.edge_style, 0, vim.empty_dict())
end

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.g.edge_style = variant.native_options.style
    vim.g.edge_dim_foreground = 0
    vim.g.edge_transparent_background = 2
    vim.g.edge_float_style = "blend"
    vim.g.edge_better_performance = 0
    vim.g.edge_disable_terminal_colors = 0
    vim.g.edge_colors_override = vim.empty_dict()
    vim.cmd.colorscheme("edge")
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
        overlay0 = native.color("Comment", "fg"), overlay1 = native.color("Comment", "fg"),
        text = p.fg[1], subtext0 = native.color("Comment", "fg"),
        mauve = p.purple[1], green = native.color("DiagnosticOk", "fg"),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"),
        peach = p.yellow[1],
    }
end

return M
