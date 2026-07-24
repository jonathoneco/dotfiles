return {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    config = function()
        -- vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])
        require("nvim-tree").setup({
            -- netrw is already disabled by lazy.nvim. Avoid nvim-tree's legacy
            -- FileExplorer autocmd cleanup, which Neovim 0.12 rejects.
            disable_netrw = true,
            hijack_netrw = false,
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
