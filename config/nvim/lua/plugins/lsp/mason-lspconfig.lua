
local mason = {
	"williamboman/mason.nvim",
	cmd = "Mason",
	event = "BufReadPre",
	opts = {
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	},
}

local mason_lspconfig = {
	"williamboman/mason-lspconfig.nvim",
	event = "BufReadPre",
	dependencies = "williamboman/mason.nvim",
	opts = {
		ensure_installed = {
			"efm",
			"lua_ls",
			"rust_analyzer",
			"gopls",
			"pyright",
			"ts_ls",
			"html",
			"cssls",
			"tailwindcss",
			"svelte",
			"graphql",
			"emmet_ls",
			"prismals",
			"bashls",
		},
		automatic_installation = true,
	},
}

return {
	mason,
	mason_lspconfig,
}
