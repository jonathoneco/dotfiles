-- All omarchy theme plugins - keeps them permanently installed
return {
	-- Catppuccin themes
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true, -- Don't load automatically, only when needed
	},

	-- Everforest
	{
		"neanias/everforest-nvim",
		lazy = true,
	},

	-- Gruvbox
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
	},

	-- Kanagawa
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
	},

	-- Matte Black
	{
		"tahayvr/matteblack.nvim",
		lazy = true,
	},

	-- Nord (Nightfox)
	{
		"EdenEast/nightfox.nvim",
		lazy = true,
	},

	-- Osaka Jade (Bamboo)
	{
		"ribru17/bamboo.nvim",
		lazy = true,
	},

	-- Ristretto (Monokai Pro)
	{
		"gthelding/monokai-pro.nvim",
		lazy = true,
	},

	-- Rose Pine
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
	},

	-- Tokyo Night
	{
		"folke/tokyonight.nvim",
		lazy = true,
	},
}