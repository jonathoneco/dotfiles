local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.cmd.colorscheme("melange")
    for _, name in ipairs({ "Normal", "NormalFloat" }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, name, hl)
    end
end

function M.palette()
    local p = require("melange/palettes/" .. vim.o.background).a
    return {
        background = p.bg, foreground = p.fg,
        cursor = p.fg, cursor_text = p.bg,
        selection_background = p.sel, selection_foreground = p.fg,
    }
end

return M
