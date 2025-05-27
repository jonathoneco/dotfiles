-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'stevearc/resession.nvim',
  config = function()
    require('resession').setup {
      autosave = {
        enabled = true,
        interval = 300, -- autosave every 5 minutes
        notify = false,
      },
    }

    -- Optional: save on exit and restore on startup per project
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        require('resession').save(vim.fn.getcwd(), { notify = false })
      end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        if vim.fn.argc() == 0 then -- Only load if no files were passed on the CLI
          local cwd = vim.fn.getcwd()
          local sessions = require('resession').list()
          for _, session in ipairs(sessions) do
            if session.name == cwd then
              require('resession').load(cwd, { notify = false })
              break
            end
          end
        end
      end,
    })
  end,
}
