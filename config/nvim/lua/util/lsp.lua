-- LSP utility functions

local M = {}

M.on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- LSP keymaps using built-in functions
	vim.keymap.set("n", "gk", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
	vim.keymap.set("n", "gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, vim.tbl_extend("force", opts, { desc = "Go to definition in split" }))
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Find implementations" }))
	vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
	vim.keymap.set("n", '<leader>vws', vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Workspace symbol search" }))
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))
	vim.keymap.set("n", "<leader>vD", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))
	vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
	vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
	vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Smart rename" }))
	vim.keymap.set("n", "<M-h>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

	if client.name == "pyright" then
		vim.keymap.set("n", "<leader>oi", function() vim.cmd("PyrightOrganizeImports") end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
		vim.keymap.set("n", "<leader>db", function() vim.cmd("DapToggleBreakpoint") end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
		vim.keymap.set("n", "<leader>dr", function() vim.cmd("DapContinue") end, vim.tbl_extend("force", opts, { desc = "Continue/invoke debugger" }))
		vim.keymap.set("n", "<leader>dt", function() require('dap-python').test_method() end, vim.tbl_extend("force", opts, { desc = "Run tests" }))
	end

	if client.name == "ts_ls" then
		vim.keymap.set("n", "<leader>oi", function() vim.cmd("TypeScriptOrganizeImports") end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
	end
end

M.typescript_organise_imports = {
	description = "Organise Imports",
	function()
		local params = {
			command = "_typescript.organizeImports",
			arguments = { vim.fn.expand("%:p") },
		}
		-- reorganise imports
		vim.lsp.buf.execute_command(params)
	end,
}

return M
