local M = {}
local native = require("config.theme_native")

local function palette(theme)
    local colors = require("github-theme.lib.color")
    local p = require("github-theme.palette").load(theme)
    colors.BG = colors(p.canvas.default)
    return require("github-theme.spec").load(theme)
end

function M.apply(variant)
    vim.o.background = variant.appearance
    local specs = {}
    for theme in pairs(require("github-theme.palette").themes) do
        specs[theme] = palette(theme)
        specs[theme].palette = nil
    end
    require("github-theme").setup({
        options = { transparent = true, terminal_colors = true },
        specs = specs,
    })
    vim.cmd.colorscheme("github_" .. variant.native_options.style)
end

function M.palette()
    local p = palette(require("github-theme.config").theme)
    return {
        background = p.bg1, foreground = p.fg1,
        cursor = p.fg1, cursor_text = p.bg1,
        selection_background = p.sel0, selection_foreground = p.fg1,
    }
end

function M.herdr(variant, spec)
    local p = palette(require("github-theme.config").theme)
    local accent = native.accent(spec, variant, native.pair("StatusLine", p.fg1, p.bg1))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = p.bg3, selection_bg = p.sel0,
        surface1 = p.bg2, surface_dim = p.palette.border.default,
        overlay0 = p.syntax.comment, overlay1 = p.fg2, text = p.fg1, subtext0 = p.fg2,
        mauve = p.palette.magenta.base, green = p.git.add, yellow = p.diag.warn, red = p.diag.error,
        blue = p.diag.info, teal = p.diag.hint, peach = p.palette.orange,
    }
end

return M
