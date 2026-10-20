local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.g.dracula_colorterm = 1
    vim.cmd.colorscheme("dracula")
    for _, name in ipairs({ "Normal", "NormalFloat" }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, name, hl)
    end
end

function M.palette()
    local p = vim.g["dracula#palette"]
    return {
        background = p.bg[1], foreground = p.fg[1],
        cursor = p.fg[1], cursor_text = p.bg[1],
        selection_background = p.selection[1], selection_foreground = p.fg[1],
    }
end

return M
