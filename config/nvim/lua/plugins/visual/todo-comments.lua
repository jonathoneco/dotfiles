-- Highlight todo, notes, etc in comments
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = { signs = false },
  -- stylua: ignore
}
