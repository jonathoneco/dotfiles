return {
	{
		"lervag/vimtex",
		lazy = false,
		ft = { "tex", "latex" },
		init = function()
			vim.g.vimtex_view_method = "zathura"
			-- vim.g.vimtex_view_general_viewer = "okular"
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_compiler_latexmk = {
				aux_dir = "build",
				out_dir = "build",
				options = {
					"-xelatex",
					"-interaction=nonstopmode",
					"-synctex=1",
				},
			}
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_syntax_enabled = 1
			vim.g.vimtex_fold_enabled = 1
			vim.g.vimtex_complete_enabled = 1
			vim.g.vimtex_complete_close_braces = 1
			vim.g.vimtex_mappings_enabled = 1
			vim.g.vimtex_imaps_enabled = 1
			vim.g.vimtex_motion_enabled = 1
			vim.g.vimtex_text_obj_enabled = 1
		end,
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "tex", "latex" },
				callback = function()
					vim.keymap.set(
						"n",
						"<leader>ll",
						"<cmd>VimtexCompile<CR>",
						{ buffer = true, desc = "Compile LaTeX" }
					)
					vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { buffer = true, desc = "View PDF" })
					vim.keymap.set(
						"n",
						"<leader>lc",
						"<cmd>VimtexClean<CR>",
						{ buffer = true, desc = "Clean auxiliary files" }
					)
					vim.keymap.set(
						"n",
						"<leader>ls",
						"<cmd>VimtexStop<CR>",
						{ buffer = true, desc = "Stop compilation" }
					)
					vim.keymap.set(
						"n",
						"<leader>lt",
						"<cmd>VimtexTocToggle<CR>",
						{ buffer = true, desc = "Toggle TOC" }
					)
					vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<CR>", { buffer = true, desc = "Show errors" })

					vim.opt_local.conceallevel = 2
					vim.opt_local.spell = true
					vim.opt_local.spelllang = "en_us"
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
				end,
			})
		end,
	},
}
