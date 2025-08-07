return {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    config = function()
        -- vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])
        require("nvim-tree").setup({
            filters = {
                dotfiles = false,
            },
            view = {
                adaptive_size = true,
                side = "right",
            },
            git = {
                enable = false,
            },
            update_focused_file = {
                enable = true
            }
        })
    end,
}
