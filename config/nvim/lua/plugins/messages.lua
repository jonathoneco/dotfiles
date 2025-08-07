return {
    "AckslD/messages.nvim",
    lazy = false,
    config = function()
        require("messages").setup({
            command_name = "Messages",
        })
    end,
}

