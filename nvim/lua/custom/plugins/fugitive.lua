-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'tpope/vim-fugitive',
  keys = {
    { '<leader>gs', '<cmd>Git<CR>', desc = 'Git Status' },
    { '<leader>gb', '<cmd>Git blame<CR>', desc = 'Git Blame' },
  },
}
