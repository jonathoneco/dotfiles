local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.cmd.colorscheme("melange")
    for _, name in ipairs({ "Normal", "NormalFloat" }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, name, hl)
    end
end

function M.palette()
    local p = require("melange/palettes/" .. vim.o.background).a
    return {
        background = p.bg, foreground = p.fg,
        cursor = p.fg, cursor_text = p.bg,
        selection_background = p.sel, selection_foreground = p.fg,
    }
end

function M.herdr(variant, spec)
    local native = require("config.theme_native")
    local p = require("melange/palettes/" .. vim.o.background)
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.a.fg, p.a.float))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = p.a.sel, surface1 = p.a.float, surface_dim = p.a.ui,
        overlay0 = p.a.com, overlay1 = p.a.com, text = p.a.fg, subtext0 = p.a.com,
        mauve = p.c.magenta, green = native.color("DiagnosticOk", "fg"),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"),
        peach = p.c.yellow,
    }
end

return M
