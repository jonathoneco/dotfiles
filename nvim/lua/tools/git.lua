return {
  -- Git signs in the gutter
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then vim.cmd.normal { ']c', bang = true }
          else gs.nav_hunk('next') end
        end, 'Jump to next git [c]hange')

        map('n', '[c', function()
          if vim.wo.diff then vim.cmd.normal { '[c', bang = true }
          else gs.nav_hunk('prev') end
        end, 'Jump to previous git [c]hange')

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, 'Git [s]tage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Git [r]eset hunk')
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') }
        end, 'Git [s]tage hunk (visual)')
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') }
        end, 'Git [r]eset hunk (visual)')
        map('n', '<leader>hS', gs.stage_buffer, 'Git [S]tage buffer')
        map('n', '<leader>hR', gs.reset_buffer, 'Git [R]eset buffer')
        map('n', '<leader>hp', gs.preview_hunk, 'Git [p]review hunk')
        map('n', '<leader>hb', gs.blame_line, 'Git [b]lame line')
        map('n', '<leader>hd', gs.diffthis, 'Git [d]iff against index')
        map('n', '<leader>hD', function() gs.diffthis('@') end, 'Git [D]iff against last commit')

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, '[T]oggle git [b]lame line')
        map('n', '<leader>tD', gs.preview_hunk_inline, '[T]oggle git show [D]eleted')
      end,
    },
  },

  -- Git command interface
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set("n", "<leader>gs", function() vim.cmd.Git() end, { desc = "[G]it [S]tatus" })
      vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>", { desc = "Get changes from left (//2)" })
      vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>", { desc = "Get changes from right (//3)" })

      local augroup = vim.api.nvim_create_augroup("FugitiveCustom", {})

      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
          if vim.bo.filetype ~= "fugitive" then return end

          local buf = vim.api.nvim_get_current_buf()
          local opts = { buffer = buf, remap = false }

          vim.keymap.set("n", "<leader>gp", function()
            vim.cmd.Git("push")
          end, vim.tbl_extend("force", opts, { desc = "[G]it [P]ush" }))

          vim.keymap.set("n", "<leader>gP", function()
            vim.cmd.Git({ "pull", "--rebase" })
          end, vim.tbl_extend("force", opts, { desc = "[G]it Pull --[R]ebase" }))

          vim.keymap.set("n", "<leader>gt", ":Git push -u origin ", opts) -- No <CR> to allow input
        end,
      })
    end,
  },
}

