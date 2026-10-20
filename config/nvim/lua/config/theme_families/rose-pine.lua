local M = {}
local native = require("config.theme_native")

function M.apply(variant)
    vim.o.background = variant.appearance
    require("rose-pine").setup({
        variant = variant.native_options.variant,
        dark_variant = variant.native_options.variant == "dawn" and "main" or variant.native_options.variant,
        styles = { transparency = true },
        enable = { terminal = true },
        highlight_groups = { NormalFloat = { bg = "NONE" } },
    })
    vim.cmd.colorscheme("rose-pine")
end

function M.palette()
    local p = require("rose-pine.palette")
    return {
        background = p.base, foreground = p.text,
        cursor = p.highlight_high, cursor_text = p.text,
        selection_background = p.highlight_med, selection_foreground = p.text,
    }
end

function M.herdr(variant, spec)
    local p = require("rose-pine.palette")
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.subtle, p.base))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = p.overlay, selection_bg = native.color("Visual", "bg"),
        surface1 = p.surface, surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = p.muted, overlay1 = p.subtle, text = p.text, subtext0 = p.subtle,
        mauve = p.iris, green = p.leaf, yellow = p.gold, red = p.love,
        blue = p.pine, teal = p.foam, peach = p.rose,
    }
end

return M
