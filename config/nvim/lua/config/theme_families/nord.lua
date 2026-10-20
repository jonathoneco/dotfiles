local M = {}
local palette

local function hex(color)
    return string.format("#%06x", color)
end

function M.apply(variant)
    vim.o.background = variant.appearance
    vim.cmd.colorscheme("nord")
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local cursor = vim.api.nvim_get_hl(0, { name = "Cursor", link = false })
    local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
    palette = {
        background = hex(normal.bg), foreground = hex(normal.fg),
        cursor = hex(cursor.bg), cursor_text = hex(cursor.fg),
        selection_background = hex(visual.bg), selection_foreground = hex(visual.fg or normal.fg),
    }
    for _, name in ipairs({ "Normal", "NormalFloat" }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, name, hl)
    end
end

function M.palette()
    return vim.deepcopy(palette)
end

return M
