vim.g.conform_debug = true

return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        markdown = { 'markdownlint' },
        python = { 'black' },
        javascript = { 'eslint' }, -- or "eslint" if you don’t use eslint
        javascriptreact = { 'eslint' },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },

      },
      formatters = {
        markdownlint = {
          prepend_args = {
            '--config',
            vim.fn.expand((os.getenv 'DOTFILES' or '~/.dotfiles') .. '/config/markdownlint.json'),
          },
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
