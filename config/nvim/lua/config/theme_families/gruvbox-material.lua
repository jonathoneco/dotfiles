local M = {}
local native = require("config.theme_native")

local function palette()
    return vim.fn["gruvbox_material#get_palette"]("medium", "material", vim.empty_dict())
end

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.g.gruvbox_material_background = "medium"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_visual = "grey background"
    vim.g.gruvbox_material_statusline_style = "default"
    vim.g.gruvbox_material_transparent_background = 2
    vim.g.gruvbox_material_float_style = "blend"
    vim.g.gruvbox_material_better_performance = 0
    vim.g.gruvbox_material_disable_terminal_colors = 0
    vim.g.gruvbox_material_colors_override = vim.empty_dict()
    vim.cmd.colorscheme("gruvbox-material")
end

function M.palette()
    local p = palette()
    local cursor = native.pair("Cursor", p.fg0[1], p.bg0[1])
    return {
        background = p.bg0[1], foreground = p.fg0[1],
        cursor = cursor.bg, cursor_text = cursor.fg,
        selection_background = native.color("Visual", "bg"), selection_foreground = p.fg0[1],
    }
end

function M.herdr(variant, spec)
    local p = palette()
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg1[1], p.bg_statusline1[1]))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = native.color("Visual", "bg"), surface1 = p.bg2[1],
        surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = p.grey1[1], overlay1 = p.grey2[1], text = p.fg0[1], subtext0 = p.grey1[1],
        mauve = p.purple[1], green = native.color("DiagnosticOk", "fg"),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = p.aqua[1], peach = p.orange[1],
    }
end

return M
