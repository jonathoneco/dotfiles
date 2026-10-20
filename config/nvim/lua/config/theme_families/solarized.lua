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

return M
