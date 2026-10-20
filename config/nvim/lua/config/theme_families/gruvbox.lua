local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("gruvbox").setup({
        contrast = "",
        transparent_mode = true,
        terminal_colors = true,
        invert_selection = false,
    })
    vim.cmd.colorscheme("gruvbox")
end

function M.palette()
    local p = require("gruvbox").palette
    local light = vim.o.background == "light"
    local bg = light and p.light0 or p.dark0
    local fg = light and p.dark1 or p.light1
    return {
        background = bg, foreground = fg,
        cursor = fg, cursor_text = bg,
        selection_background = light and p.light3 or p.dark3, selection_foreground = fg,
    }
end

function M.herdr(variant, spec)
    local native = require("config.theme_native")
    local p = M.palette()
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.foreground, p.background))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = p.selection_background, surface1 = native.color("CursorLine", "bg"),
        surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = native.color("Comment", "fg"), overlay1 = native.color("GruvboxFg4", "fg"),
        text = p.foreground, subtext0 = native.color("Comment", "fg"),
        mauve = native.color("GruvboxPurple", "fg"), green = native.color("DiagnosticOk", "fg"),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"),
        peach = native.color("GruvboxOrange", "fg"),
    }
end

return M
