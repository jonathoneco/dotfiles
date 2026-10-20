local M = {}

function M.apply(variant)
    assert(vim.tbl_contains({ "hard", "medium", "soft" }, variant.native_options.contrast), "invalid Everforest contrast")
    vim.g.everforest_background = variant.native_options.contrast
    vim.g.everforest_transparent_background = 2
    vim.g.everforest_float_style = "blend"
    vim.g.everforest_better_performance = 0
    vim.g.everforest_colors_override = vim.empty_dict()
    vim.o.background = variant.appearance
    vim.cmd.colorscheme("everforest")
    for _, name in ipairs({ "Pmenu", "PmenuSbar", "PmenuKind", "PmenuExtra" }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, name, hl)
    end
end

function M.palette()
    local p = vim.fn["everforest#get_palette"](vim.g.everforest_background, vim.empty_dict())
    return {
        background = p.bg0[1], foreground = p.fg[1],
        cursor = p.orange[1], cursor_text = p.bg0[1],
        selection_background = p.bg_visual[1], selection_foreground = p.fg[1],
    }
end

return M
