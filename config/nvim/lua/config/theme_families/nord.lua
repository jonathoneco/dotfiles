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

function M.herdr(variant, spec)
    local native = require("config.theme_native")
    local accent = native.accent(spec, variant, native.pair("StatusLine", palette.foreground, palette.background))
    return {
        accent = accent.bg, accent_text = accent.fg,
        panel_bg = "reset", sidebar_bg = "reset", surface0 = "reset",
        active_row_bg = native.color("CursorLine", "bg"),
        selection_bg = palette.selection_background, surface1 = native.color("CursorLine", "bg"),
        surface_dim = native.color("VertSplit", "fg"),
        overlay0 = native.color("Comment", "fg"), overlay1 = native.color("Comment", "fg"),
        text = palette.foreground, subtext0 = native.color("Comment", "fg"),
        mauve = native.color("Number", "fg"), green = native.hex(vim.g.terminal_color_2),
        yellow = native.color("DiagnosticWarn", "fg"), red = native.color("DiagnosticError", "fg"),
        blue = native.color("DiagnosticInfo", "fg"), teal = native.color("DiagnosticHint", "fg"),
        peach = native.color("Decorator", "fg"),
    }
end

return M
