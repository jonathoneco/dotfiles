return {
	{ "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{ "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
	{ "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000 },
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "darker",
			})
		end,
	},
	{ "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
	{
		"neanias/everforest-nvim",
		version = false,
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		-- Optional; default configuration will be used if setup isn't called.
		config = function()
			require("everforest").setup({
				-- Your config here
			})
		end,
	},
	{
		"luisiacc/gruvbox-baby",
		lazy = false,
	},
}
