local M = {}
local native = require("config.theme_native")

function M.apply(variant)
    vim.o.background = variant.appearance
    require("tokyonight").setup({
        style = variant.native_options.style,
        transparent = true,
        terminal_colors = true,
        styles = { sidebars = "transparent", floats = "transparent" },
    })
    vim.cmd.colorscheme("tokyonight-" .. variant.native_options.style)
end

function M.palette()
    local p = require("tokyonight.colors").setup()
    return {
        background = p.bg, foreground = p.fg,
        cursor = p.fg, cursor_text = p.bg,
        selection_background = p.bg_visual, selection_foreground = p.fg,
    }
end

function M.herdr(variant, spec)
    local p = require("tokyonight.colors").setup()
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg_sidebar, p.bg_statusline))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = p.bg_highlight, selection_bg = p.bg_visual,
        surface1 = p.bg_highlight, surface_dim = p.border,
        overlay0 = p.comment, overlay1 = p.fg_dark, text = p.fg, subtext0 = p.fg_dark,
        mauve = p.magenta, green = p.green, yellow = p.warning, red = p.error,
        blue = p.info, teal = p.hint, peach = p.orange,
    }
end

return M
