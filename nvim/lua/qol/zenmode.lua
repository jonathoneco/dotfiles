return {
    "folke/zen-mode.nvim",
    config = function()
        vim.keymap.set("n", "<leader>z", function()
            require("zen-mode").setup {
                window = {
                    width = 90,
                    options = { }
                },
            }
            require("zen-mode").toggle()
            vim.wo.wrap = not vim.wo.wrap
            vim.wo.number = not vim.wo.number
            vim.wo.rnu = not vim.wo.rnu
            vim.opt.colorcolumn = vim.opt.colorcolumn:get() == "0" and "80" or "0"
        end)
    end
}


