local config = function()
    local opts = {
        options = {
            theme = require("config.theme_families").statusline_theme(),
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
    vim.api.nvim_create_autocmd("User", {
        pattern = "ThemeApplied",
        group = vim.api.nvim_create_augroup("lualine_theme", {}),
        callback = function()
            opts.options.theme = require("config.theme_families").statusline_theme()
            require("lualine").setup(opts)
        end,
    })
end

return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    config = config,
}
