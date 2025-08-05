return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ft = { 'markdown', 'quarto', 'rmd' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function ()
        require('render-markdown').setup({
            completions = { lsp = { enabled = true } },
        })
    end
}
