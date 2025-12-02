return {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        -- config = function()
        --     vim.cmd([[colorscheme kanagawa-dragon]])
        -- end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        config = function()
            vim.cmd("colorscheme rose-pine")
        end
    }
}
