local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("nightfox").setup({
        options = { transparent = true, terminal_colors = true },
        groups = { all = { NormalFloat = { bg = "NONE" }, FloatBorder = { bg = "NONE" } } },
    })
    vim.cmd.colorscheme(variant.native_options.style)
end

function M.palette()
    local p = require("nightfox.spec").load(vim.g.colors_name)
    return {
        background = p.bg1, foreground = p.fg1,
        cursor = p.fg1, cursor_text = p.bg1,
        selection_background = p.sel0, selection_foreground = p.fg1,
    }
end

function M.herdr(variant, spec)
    local native = require("config.theme_native")
    local p = require("nightfox.spec").load(vim.g.colors_name)
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg2, p.bg0))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = p.sel0, surface1 = p.bg0, surface_dim = native.color("FloatBorder", "fg"),
        overlay0 = p.syntax.comment, overlay1 = p.fg3, text = p.fg1, subtext0 = p.fg2,
        mauve = p.palette.magenta.base, green = p.diag.ok,
        yellow = p.diag.warn, red = p.diag.error, blue = p.diag.info, teal = p.diag.hint,
        peach = p.palette.orange.base,
    }
end

return M
