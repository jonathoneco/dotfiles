-- Check if jupyter plugins should be enabled (default: true)
-- Set vim.g.enable_jupyter = false to disable all jupyter/notebook plugins
if vim.g.enable_jupyter == false then
	return {}
end

return {
	-- plugins/quarto.lua
	{
		"GCBallesteros/jupytext.nvim",
		config = true,
		-- Depending on your nvim distro or config you may need to make the loading not lazy
		-- lazy=false,
	},
	{
		"nvimtools/hydra.nvim",
	},
	{
		"quarto-dev/quarto-nvim",
		ft = { "quarto", "markdown" },
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			lspFeatures = {
				-- NOTE: put whatever languages you want here:
				languages = { "r", "python", "rust" },
				chunks = "all",
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			keymap = {
				-- NOTE: setup your own keymaps:
				hover = "K",
				definition = "gd",
				rename = "<leader>vrn",
				references = "vrr",
				format = "<leader>vf",
			},
			codeRunner = {
				enabled = true,
				default_method = "molten",
			},
		},
	},
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = {
			"3rd/image.nvim",
			"quarto-dev/quarto-nvim",
			"GCBallesteros/jupytext.nvim",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":UpdateRemotePlugins",
		init = function()
			-- these are examples, not defaults. Please see the readme
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true

			vim.keymap.set("n", "<localleader>ip", function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv ~= nil then
					-- Get the parent directory name instead of the venv folder name
					-- /home/jonco/src/recommender/.venv -> recommender
					local kernel_name = string.match(venv, "/([^/]+)/%.?[vV]env")
					if kernel_name then
						vim.cmd(("MoltenInit %s"):format(kernel_name))
					else
						vim.cmd("MoltenInit python3")
					end
				else
					vim.cmd("MoltenInit python3")
				end
			end, { desc = "Initialize Molten for project kernel", silent = true })
			vim.keymap.set(
				"n",
				"<localleader>e",
				":MoltenEvaluateOperator<CR>",
				{ desc = "evaluate operator", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>os",
				":noautocmd MoltenEnterOutput<CR>",
				{ desc = "open output window", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>rr",
				":MoltenReevaluateCell<CR>",
				{ desc = "re-eval cell", silent = true }
			)
			vim.keymap.set(
				"v",
				"<localleader>r",
				":<C-u>MoltenEvaluateVisual<CR>gv",
				{ desc = "execute visual selection", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>oh",
				":MoltenHideOutput<CR>",
				{ desc = "close output window", silent = true }
			)
			vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

			-- if you work with html outputs:
			vim.keymap.set(
				"n",
				"<localleader>mx",
				":MoltenOpenInBrowser<CR>",
				{ desc = "open output in browser", silent = true }
			)
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
			vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
			vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
			vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
			vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
			vim.keymap.set("n", "<localleader>RA", function()
				runner.run_all(true)
			end, { desc = "run all cells of all languages", silent = true })
			require("jupytext").setup({
				style = "markdown",
				output_extension = "md",
				force_ft = "markdown",
			})

			-- Setup treesitter text objects for code cells
			-- Navigation
			vim.keymap.set({ "n", "x", "o" }, "]b", function()
				require("nvim-treesitter.textobjects.move").goto_next_start("@code_cell.inner")
			end, { desc = "Next code cell" })

			vim.keymap.set({ "n", "x", "o" }, "[b", function()
				require("nvim-treesitter.textobjects.move").goto_previous_start("@code_cell.inner")
			end, { desc = "Previous code cell" })

			vim.keymap.set({ "n", "x", "o" }, "]B", function()
				require("nvim-treesitter.textobjects.move").goto_next_end("@code_cell.inner")
			end, { desc = "End of code cell" })

			vim.keymap.set({ "n", "x", "o" }, "[B", function()
				require("nvim-treesitter.textobjects.move").goto_previous_end("@code_cell.inner")
			end, { desc = "Start of code cell" })

			-- Selection
			vim.keymap.set({ "x", "o" }, "ib", function()
				require("nvim-treesitter.textobjects.select").select_textobject("@code_cell.inner", "textobjects")
			end, { desc = "Inside code cell" })

			vim.keymap.set({ "x", "o" }, "ab", function()
				require("nvim-treesitter.textobjects.select").select_textobject("@code_cell.outer", "textobjects")
			end, { desc = "Around code cell" })

			-- Automatically import output chunks from a jupyter notebook
			-- Tries to find a kernel that matches the kernel in the jupyter notebook
			-- Falls back to a kernel that matches the name of the active venv (if any)
			local imb = function(e) -- init molten buffer
				vim.schedule(function()
					local kernels = vim.fn.MoltenAvailableKernels()
					local try_kernel_name = function()
						local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
						return metadata.kernelspec.name
					end
					local ok, kernel_name = pcall(try_kernel_name)
					if not ok or not vim.tbl_contains(kernels, kernel_name) then
						kernel_name = nil
						local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
						if venv ~= nil then
							kernel_name = string.match(venv, "/.+/(.+)")
						end
					end
					if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
						vim.cmd(("MoltenInit %s"):format(kernel_name))
					end
					vim.cmd("MoltenImportOutput")
				end)
			end

			-- Automatically import output chunks from a jupyter notebook
			vim.api.nvim_create_autocmd("BufAdd", {
				pattern = { "*.ipynb" },
				callback = imb,
			})

			-- We have to do this as well so that we catch files opened like nvim ./hi.ipynb
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.ipynb" },
				callback = function(e)
					if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
						imb(e)
					end
				end,
			})

			-- Automatically export output chunks to a jupyter notebook on write
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = { "*.ipynb" },
				callback = function()
					if require("molten.status").initialized() == "Molten" then
						vim.cmd("MoltenExportOutput!")
					end
				end,
			})

			-- Setup hydra for convenient notebook navigation
			local function keys(str)
				return function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(str, true, false, true), "m", true)
				end
			end

			local hydra = require("hydra")
			hydra({
				name = "QuartoNavigator",
				hint = [[
  _j_/_k_: move down/up  _r_: run cell
  _l_: run line  _R_: run above
  ^^     _<esc>_/_q_: exit ]],
				config = {
					color = "pink",
					invoke_on_body = true,
					hint = {
						float_opts = {
							border = "rounded",
						},
					},
				},
				mode = { "n" },
				body = "<localleader>j", -- this is the key that triggers the hydra
				heads = {
					{ "j", keys("]b") },
					{ "k", keys("[b") },
					{ "r", ":QuartoSend<CR>" },
					{ "l", ":QuartoSendLine<CR>" },
					{ "R", ":QuartoSendAbove<CR>" },
					{ "<esc>", nil, { exit = true } },
					{ "q", nil, { exit = true } },
				},
			})

			-- Disable annoying pyright diagnostic for unused expressions in notebook cells
			-- It's common to leave an unused expression at the bottom of a cell as a way of printing
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "pyright" then
						client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
							python = {
								analysis = {
									diagnosticSeverityOverrides = {
										reportUnusedExpression = "none",
									},
								},
							},
						})
						client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					end
				end,
			})

			-- Change the configuration when editing a python file
			-- In .py files, disable virtual text to avoid clutter
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*.py",
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					if require("molten.status").initialized() == "Molten" then
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
						vim.fn.MoltenUpdateOption("virt_text_output", false)
					else
						vim.g.molten_virt_lines_off_by_1 = false
						vim.g.molten_virt_text_output = false
					end
				end,
			})

			-- Undo those config changes when we go back to a markdown or quarto file
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.qmd", "*.md", "*.ipynb" },
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					if require("molten.status").initialized() == "Molten" then
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
						vim.fn.MoltenUpdateOption("virt_text_output", true)
					else
						vim.g.molten_virt_lines_off_by_1 = true
						vim.g.molten_virt_text_output = true
					end
				end,
			})

			-- Provide a command to create a blank new Python notebook
			-- Note: the metadata is needed for Jupytext to understand how to parse the notebook
			local default_notebook = [[
{
  "cells": [
   {
    "cell_type": "markdown",
    "metadata": {},
    "source": [
      ""
    ]
   }
  ],
  "metadata": {
   "kernelspec": {
    "display_name": "Python 3",
    "language": "python",
    "name": "python3"
   },
   "language_info": {
    "codemirror_mode": {
      "name": "ipython"
    },
    "file_extension": ".py",
    "mimetype": "text/x-python",
    "name": "python",
    "nbconvert_exporter": "python",
    "pygments_lexer": "ipython3"
   }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
]]

			local function new_notebook(filename)
				local path = filename .. ".ipynb"
				local file = io.open(path, "w")
				if file then
					file:write(default_notebook)
					file:close()
					vim.cmd("edit " .. path)
				else
					print("Error: Could not open new notebook file for writing.")
				end
			end

			vim.api.nvim_create_user_command("NewNotebook", function(opts)
				new_notebook(opts.args)
			end, {
				nargs = 1,
				complete = "file",
			})
		end,
	},
	{
		-- see the image.nvim readme for more information about configuring this plugin
		"3rd/image.nvim",
		opts = {
			backend = "kitty", -- whatever backend you would like to use
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
