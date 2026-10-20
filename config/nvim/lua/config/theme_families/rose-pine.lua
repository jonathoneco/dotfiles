local M = {}

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

return M
