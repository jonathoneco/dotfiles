return {
  'lervag/vimtex',
  ft = 'tex',
  init = function()
    -- Use Skim for PDF viewing
    vim.g.vimtex_view_method = 'skim'
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1

    -- Use latexmk for compilation
    vim.g.vimtex_compiler_method = 'latexmk'

    -- Optional: don't close quickfix window on compile error
    vim.g.vimtex_quickfix_mode = 0

    -- Disable default keymaps so we control them ourselves
    vim.g.vimtex_compiler_latexmk = {
      callback = 1,
      continuous = 1,
      executable = 'latexmk',
      aux_dir = 'build',
      options = {
        '-xelatex',
        '-file-line-error',
        '-pdf',
        '-interaction=nonstopmode',
        '-synctex=1',
        '-shell-escape',
      },
    }
  end,
}
