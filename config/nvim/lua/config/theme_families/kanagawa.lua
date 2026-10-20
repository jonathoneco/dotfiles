local M = {}

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

return M
