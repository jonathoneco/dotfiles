local M = {}

function M.apply(variant)
    vim.o.background = variant.appearance
    require("github-theme").setup({ options = { transparent = true, terminal_colors = true } })
    vim.cmd.colorscheme("github_" .. variant.native_options.style)
end

function M.palette()
    local p = require("github-theme.spec").load(require("github-theme.config").theme)
    return {
        background = p.bg1, foreground = p.fg1,
        cursor = p.fg1, cursor_text = p.bg1,
        selection_background = p.sel0, selection_foreground = p.fg1,
    }
end

return M
