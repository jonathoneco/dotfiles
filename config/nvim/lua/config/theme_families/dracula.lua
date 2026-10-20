local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.g.dracula_colorterm = 1
    vim.cmd.colorscheme("dracula")
    for _, name in ipairs({ "Normal", "NormalFloat" }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, name, hl)
    end
end

function M.palette()
    local p = vim.g["dracula#palette"]
    return {
        background = p.bg[1], foreground = p.fg[1],
        cursor = p.fg[1], cursor_text = p.bg[1],
        selection_background = p.selection[1], selection_foreground = p.fg[1],
    }
end

function M.herdr(variant, spec)
    local native = require("config.theme_native")
    local p = vim.g["dracula#palette"]
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg[1], p.bglighter[1]))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = p.selection[1], surface1 = p.bglight[1], surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = p.comment[1], overlay1 = p.comment[1], text = p.fg[1], subtext0 = p.comment[1],
        mauve = p.purple[1], green = native.hex(vim.g.terminal_color_2),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"), peach = p.orange[1],
    }
end

return M
