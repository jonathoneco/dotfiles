local M = {}
local native = require("config.theme_native")

function M.apply(variant)
    vim.o.background = variant.appearance
    require("catppuccin").setup({
        flavour = variant.native_options.flavour,
        transparent_background = true,
        float = { transparent = true, solid = false },
        term_colors = true,
    })
    vim.cmd.colorscheme("catppuccin-" .. variant.native_options.flavour)
end

function M.palette()
    local p = require("catppuccin.palettes").get_palette()
    return {
        background = p.base, foreground = p.text,
        cursor = p.rosewater, cursor_text = p.base,
        selection_background = p.surface1, selection_foreground = p.text,
    }
end

function M.herdr(variant, spec)
    local p = require("catppuccin.palettes").get_palette()
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.text, p.base))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"), selection_bg = p.surface1,
        surface1 = p.surface0, surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = p.overlay0, overlay1 = p.overlay1, text = p.text, subtext0 = p.subtext0,
        mauve = p.mauve, green = p.green, yellow = p.yellow, red = p.red,
        blue = p.blue, teal = p.teal, peach = p.peach,
    }
end

return M
