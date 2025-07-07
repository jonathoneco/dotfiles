return {
    "folke/zen-mode.nvim",
    config = function()
        require("zen-mode").setup {
            window = {
                width = 90,
                options = { }
            },
            on_open = function()
                vim.wo.wrap = true
                vim.wo.number = false
                vim.wo.rnu = false
                vim.opt.colorcolumn = "0"
                vim.wo.signcolumn = "no"
            end,
            on_close = function()
                vim.wo.wrap = false
                vim.wo.number = true
                vim.wo.rnu = true
                vim.opt.colorcolumn = "80"
                vim.wo.signcolumn = "yes"
            end,
        }
        vim.keymap.set("n", "<leader>z", function()
            require("zen-mode").toggle()
        end, {desc = "Toggle Zen Mode"})
    end
}
