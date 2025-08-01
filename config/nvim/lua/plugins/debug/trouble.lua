local diagnostic_signs = require("util.icons").diagnostic_signs

return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		signs = {
			-- icons / text used for a diagnostic
			error = diagnostic_signs.Error,
			warning = diagnostic_signs.Warn,
			hint = diagnostic_signs.Hint,
			information = diagnostic_signs.Info,
			other = diagnostic_signs.Info,
		},
	},
  lazy = false,
	keys = {
		{ "<leader>xx", function() require("trouble").toggle() end, desc = "Toggle Trouble" },
		{ "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, desc = "Show Workspace Diagnostics" },
		{ "<leader>xd", function() require("trouble").toggle("document_diagnostics") end, desc = "Show Document Diagnostics" },
		{ "<leader>xq", function() require("trouble").toggle("quickfix") end, desc = "Toggle Quickfix List" },
		{ "<leader>xl", function() require("trouble").toggle("loclist") end, desc = "Toggle Location List" },
		{ "gR", function() require("trouble").toggle("lsp_references") end, desc = "Toggle LSP References" },
	},
}
