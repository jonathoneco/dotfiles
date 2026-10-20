local M = {}
local native = require("config.theme_native")

function M.apply(variant)
    vim.o.background = variant.appearance
    require("ayu").setup({
        mirage = variant.native_options.mirage,
        terminal = true,
        overrides = { Normal = { bg = "NONE" }, NormalFloat = { bg = "NONE" } },
    })
    vim.cmd.colorscheme("ayu")
end

function M.palette()
    local p = require("ayu.colors")
    return {
        background = p.bg, foreground = p.fg,
        cursor = p.fg, cursor_text = p.bg,
        selection_background = p.selection_inactive, selection_foreground = p.fg,
    }
end

function M.herdr(variant, spec)
    local p = require("ayu.colors")
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg, p.panel_bg))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = p.line, selection_bg = p.selection_inactive,
        surface1 = p.panel_bg, surface_dim = p.panel_border,
        overlay0 = p.comment, overlay1 = p.fg_idle, text = p.fg, subtext0 = p.fg_idle,
        mauve = p.constant, green = p.string,
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"),
        peach = p.keyword,
    }
end

return M
