local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("gruvbox").setup({
        contrast = "",
        transparent_mode = true,
        terminal_colors = true,
        invert_selection = false,
    })
    vim.cmd.colorscheme("gruvbox")
end

function M.palette()
    local p = require("gruvbox").palette
    local light = vim.o.background == "light"
    local bg = light and p.light0 or p.dark0
    local fg = light and p.dark1 or p.light1
    return {
        background = bg, foreground = fg,
        cursor = fg, cursor_text = bg,
        selection_background = light and p.light3 or p.dark3, selection_foreground = fg,
    }
end

return M
