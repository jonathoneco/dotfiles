local M = {}

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

return M
