local M = {}
local native = require("config.theme_native")
local palette

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.g.zenbones_compat = 1
    vim.cmd.colorscheme("zenbones")
    local normal = native.pair("Normal")
    local cursor = native.pair("Cursor", normal.fg, normal.bg)
    palette = {
        background = normal.bg, foreground = normal.fg,
        cursor = cursor.bg, cursor_text = cursor.fg,
        selection_background = native.color("Visual", "bg"), selection_foreground = normal.fg,
    }
    for _, name in ipairs({ "Normal", "NormalFloat" }) do
        local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
        highlight.bg = nil
        vim.api.nvim_set_hl(0, name, highlight)
    end
end

function M.palette()
    return vim.deepcopy(palette)
end

function M.herdr(variant, spec)
    local p = M.palette()
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.foreground, p.background))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = p.selection_background, surface1 = native.color("StatusLine", "bg"),
        surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = native.color("Comment", "fg"), overlay1 = native.color("NonText", "fg"),
        text = p.foreground, subtext0 = native.color("Comment", "fg"),
        mauve = native.color("DiagnosticHint", "fg"), green = native.color("DiagnosticOk", "fg"),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = vim.g.terminal_color_6,
        peach = vim.g.terminal_color_3,
    }
end

return M
