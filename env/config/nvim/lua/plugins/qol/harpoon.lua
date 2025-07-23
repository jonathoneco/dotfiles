return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()
    vim.keymap.set('n', '<leader>hpa', function()
      harpoon:list():add()
    end, { desc = 'Harpoon add file' })
    vim.keymap.set('n', '<leader>hpl', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon UI' })

    vim.keymap.set('n', '<leader>hp1', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon to file 1' })
    vim.keymap.set('n', '<leader>hp2', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon to file 2' })
    vim.keymap.set('n', '<leader>hp3', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon to file 3' })
    vim.keymap.set('n', '<leader>hp4', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon to file 4' })
  end,
}
