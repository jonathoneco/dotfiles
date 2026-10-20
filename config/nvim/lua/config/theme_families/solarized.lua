local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("solarized").setup({
        palette = "solarized",
        variant = variant.native_options.variant,
        transparent = { enabled = true, normal = true, normalfloat = true },
        plugins = { lspconfig = true },
    })
    vim.cmd.colorscheme("solarized")
end

function M.palette()
    local p = require("solarized.utils").get_colors()
    local light = vim.o.background == "light"
    local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
    return {
        background = light and p.base3 or p.base03,
        foreground = light and p.base00 or p.base0,
        cursor = light and p.base00 or p.base0,
        cursor_text = light and p.base3 or p.base03,
        selection_background = string.format("#%06x", visual.bg),
        selection_foreground = string.format("#%06x", visual.fg),
    }
end

function M.herdr(variant, spec)
    local native = require("config.theme_native")
    local p = require("solarized.utils").get_colors()
    local terminal = M.palette()
    local accent = native.accent(spec, variant, native.pair("StatusLine", terminal.foreground, terminal.background))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = terminal.selection_background,
        surface1 = vim.o.background == "light" and p.base4 or p.base04,
        surface_dim = native.color("WinSeparator", "fg"),
        overlay0 = native.color("Comment", "fg"), overlay1 = native.color("Comment", "fg"),
        text = terminal.foreground, subtext0 = native.color("Comment", "fg"),
        mauve = p.violet, green = native.color("DiagnosticOk", "fg"),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"), peach = p.orange,
    }
end

return M
