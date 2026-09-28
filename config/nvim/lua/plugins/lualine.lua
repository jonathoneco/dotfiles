-- lualine's auto theme copies colors from Neovim's highlight groups. The theme
-- glue (plugins/theme.lua) clears their backgrounds so Ghostty's opacity shows
-- through, which the auto theme reads as black. So sections b and c stay
-- transparent, and text that fell back to black takes the terminal background
-- the glue records in vim.g.terminal_bg.
local function transparent_auto()
    package.loaded["lualine.themes.auto"] = nil
    local theme = require("lualine.themes.auto")
    for _, mode in pairs(theme) do
        for section, colors in pairs(mode) do
            if section ~= "a" then
                colors.bg = "None"
            end
            if colors.fg == "#000000" and vim.g.terminal_bg then
                colors.fg = vim.g.terminal_bg
            end
        end
    end
    return theme
end

local config = function()
    local opts = {
        options = {
            theme = transparent_auto(),
            globalstatus = true,
            component_separators = { left = "|", right = "|" },
            section_separators = { left = "", right = "" },
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "buffer" },
            lualine_x = { "encoding", "fileformat", "filetype", "progress" },
            lualine_y = {},
            lualine_z = { "location" },
        },
        tabline = {},
    }
    require("lualine").setup(opts)

    -- Rebuild the theme when the terminal's colors change.
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("lualine_transparent", {}),
        callback = function()
            opts.options.theme = transparent_auto()
            require("lualine").setup(opts)
        end,
    })
end

return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    config = config,
}
