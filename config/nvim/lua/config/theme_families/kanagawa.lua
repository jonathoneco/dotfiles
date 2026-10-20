local M = {}
local native = require("config.theme_native")

function M.apply(variant)
    vim.o.background = variant.appearance
    require("kanagawa").setup({
        theme = variant.native_options.theme,
        background = { dark = variant.native_options.theme == "lotus" and "wave" or variant.native_options.theme, light = "lotus" },
        transparent = true,
        terminalColors = true,
        compile = false,
        overrides = function()
            return { NormalFloat = { bg = "NONE" }, FloatBorder = { bg = "NONE" } }
        end,
    })
    vim.cmd.colorscheme("kanagawa-" .. variant.native_options.theme)
end

function M.palette()
    local p = require("kanagawa.colors").setup().theme.ui
    return {
        background = p.bg, foreground = p.fg,
        cursor = p.fg, cursor_text = p.bg,
        selection_background = p.bg_visual, selection_foreground = p.fg,
    }
end

function M.herdr(variant, spec)
    local p = require("kanagawa.colors").setup().theme
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.ui.fg_dim, p.ui.bg_m3))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = p.ui.bg_p2, selection_bg = p.ui.bg_visual,
        surface1 = p.ui.bg_p1, surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = p.syn.comment, overlay1 = p.ui.fg_dim, text = p.ui.fg, subtext0 = p.ui.fg_dim,
        mauve = p.syn.keyword, green = p.diag.ok, yellow = p.diag.warning, red = p.diag.error,
        blue = p.diag.info, teal = p.diag.hint, peach = p.syn.constant,
    }
end

return M
