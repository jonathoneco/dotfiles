-- All keymaps converted to instant function calls for better responsiveness

-- General
local map = vim.keymap.set
vim.g.mapleader = " " -- Set <leader> to space

map("n", "\\", function()
	vim.cmd("Oil")
end, { desc = "F:le Tree" })
map("i", "<C-c>", "<Esc>", { desc = "Exit insert mode (Ctrl+C)" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard (insert mode)" })

-- digraph
map("i", "<C-M-k>", "<C-k>", { remap = false, desc = "Insert digraph" })

-- Buffer Navigation - converted to instant function calls
map("n", "<leader>bn", function()
	vim.cmd("bnext")
end, { desc = "Next buffer" })
map("n", "<leader>bp", function()
	vim.cmd("bprevious")
end, { desc = "Previous buffer" })
map("n", "<leader>bb", function()
	vim.cmd("e #")
end, { desc = "Switch to other buffer" })
map("n", "<leader>`", function()
	vim.cmd("e #")
end, { desc = "Switch to other buffer" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line(s) down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line(s) up" })

-- Join lines while keeping cursor position
map("n", "J", "mzJ`z", { desc = "Join lines (preserve cursor)" })

-- Half-page jumps centered
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })

-- Centered next/previous search results
map("n", "n", "nzzzv", { desc = "Next search (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search (centered)" })

-- Formatting
-- map("n", "<leader>f", function()
--     require("conform").format({ bufnr = 0 })
-- end, { desc = "Format buffer with Conform" })
map("n", "=ap", "ma=ap'a", { desc = "Indent paragraph and return to position" })

-- Paste over selection without yanking it
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Clipboard paste/yank
map({ "n", "v" }, "<leader>P", '"+p', { desc = "Paste from clipboard" })
map({ "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

map("n", "Q", "<nop>", { desc = "Disable Q (ex mode)" })

-- Jump through diagnostics or location lists
map("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix (centered)" })
map("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Next quickfix (centered)" })
map("n", "<leader>k", "<cmd>lprev<CR>zz", { desc = "Next location list item (centered)" })
map("n", "<leader>j", "<cmd>lnext<CR>zz", { desc = "Previous location list item (centered)" })

-- Utils
map("n", "<C-s>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })
map("v", "<C-s>", [["zy:%s/<C-r>z/<C-r>z/gI<Left><Left><Left>]], { desc = "Substitute selected text" })

map("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Go Keymaps
map("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { desc = "Insert err check with return" })
map("n", "<leader>ea", 'oassert.NoError(err, "")<Esc>F";a', { desc = "Insert assert.NoError(err)" })
map(
	"n",
	"<leader>ef",
	'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj',
	{ desc = "Insert err check with log.Fatalf" }
)
map(
	"n",
	"<leader>el",
	'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i',
	{ desc = "Insert err check with logger.Error" }
)

-- Add undo break-points
map("i", ",", ",<c-g>u", { desc = "Undo breakpoint after comma" })
map("i", ".", ".<c-g>u", { desc = "Undo breakpoint after period" })
map("i", "?", "?<c-g>u", { desc = "Undo breakpoint after question mark" })
map("i", "!", "!<c-g>u", { desc = "Undo breakpoint after exclamation mark" })
map("i", ";", ";<c-g>u", { desc = "Undo breakpoint after semicolon" })

-- better indenting
map("v", "<", "<gv", { desc = "Indent left (preserve selection)" })
map("v", ">", ">gv", { desc = "Indent right (preserve selection)" })

-- commenting
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })

-- Copying for AI
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Copy relative path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Copy full path", silent = true })
map("n", "<leader>yl", function()
	local file_path = vim.fn.expand("%:~:.")
	local line_num = vim.fn.line(".")
	local reference = file_path .. ":" .. line_num
	vim.fn.setreg("+", reference)
	print("Copied: " .. reference)
end, { desc = "Copy line reference (file:line)", silent = false })

map("n", "<leader>ym", function()
	local file_path = vim.fn.expand("%:~:.")

	-- Get current node and find parent function
	local current_node = vim.treesitter.get_node()
	if not current_node then
		print("No treesitter node found")
		return
	end

	-- Function node types for different languages
	local function_types = {
		"function_declaration",
		"function_definition",
		"method_declaration",
		"method_definition",
		"function_item", -- Rust
		"arrow_function", -- JavaScript
		"function_expression", -- JavaScript
		"local_function", -- Lua
	}

	-- Walk up the tree to find a function node
	local function_node = current_node
	while function_node do
		local node_type = function_node:type()
		for _, func_type in ipairs(function_types) do
			if node_type == func_type then
				local start_row = function_node:start()
				local reference = file_path .. ":" .. (start_row + 1) -- Convert 0-based to 1-based
				vim.fn.setreg("+", reference)
				print("Copied: " .. reference)
				return
			end
		end
		function_node = function_node:parent()
	end

	-- Fallback to current line if no function found
	local current_line = vim.fn.line(".")
	local reference = file_path .. ":" .. current_line
	vim.fn.setreg("+", reference)
	print("Copied (fallback): " .. reference)
end, { desc = "Copy method reference (file:line)", silent = false })

-- Copy current line's diagnostic(s)
map("n", "<leader>yd", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diagnostics == 0 then
		print("No diagnostics on current line")
		return
	end
	local messages = {}
	for _, diag in ipairs(diagnostics) do
		local severity = vim.diagnostic.severity[diag.severity]
		table.insert(messages, string.format("[%s] %s", severity, diag.message))
	end
	local file_path = vim.fn.expand("%:~:.")
	local line_num = vim.fn.line(".")
	local result = file_path .. ":" .. line_num .. "\n" .. table.concat(messages, "\n")
	vim.fn.setreg("+", result)
	print("Copied " .. #diagnostics .. " diagnostic(s)")
end, { desc = "Copy line diagnostics", silent = false })

-- Copy all buffer diagnostics
map("n", "<leader>yD", function()
	local diagnostics = vim.diagnostic.get(0)
	if #diagnostics == 0 then
		print("No diagnostics in buffer")
		return
	end
	local file_path = vim.fn.expand("%:~:.")
	local messages = { "Diagnostics for " .. file_path .. ":" }
	for _, diag in ipairs(diagnostics) do
		local severity = vim.diagnostic.severity[diag.severity]
		table.insert(messages, string.format("  Line %d: [%s] %s", diag.lnum + 1, severity, diag.message))
	end
	local result = table.concat(messages, "\n")
	vim.fn.setreg("+", result)
	print("Copied " .. #diagnostics .. " diagnostic(s)")
end, { desc = "Copy all buffer diagnostics", silent = false })

-- Copy visual selection with file:line reference
map("v", "<leader>yc", function()
	-- Get visual selection range
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	-- Get the selected lines
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local file_path = vim.fn.expand("%:~:.")

	local header
	if start_line == end_line then
		header = file_path .. ":" .. start_line
	else
		header = file_path .. ":" .. start_line .. "-" .. end_line
	end

	local result = header .. "\n```\n" .. table.concat(lines, "\n") .. "\n```"
	vim.fn.setreg("+", result)
	print("Copied " .. #lines .. " line(s) with reference")
	-- Exit visual mode
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Copy selection with file reference", silent = false })

-- Copy entire function/method with reference
map("n", "<leader>yM", function()
	local file_path = vim.fn.expand("%:~:.")

	local current_node = vim.treesitter.get_node()
	if not current_node then
		print("No treesitter node found")
		return
	end

	local function_types = {
		"function_declaration",
		"function_definition",
		"method_declaration",
		"method_definition",
		"function_item",
		"arrow_function",
		"function_expression",
		"local_function",
	}

	local function_node = current_node
	while function_node do
		local node_type = function_node:type()
		for _, func_type in ipairs(function_types) do
			if node_type == func_type then
				local start_row, _, end_row, _ = function_node:range()
				local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
				local header = file_path .. ":" .. (start_row + 1) .. "-" .. (end_row + 1)
				local result = header .. "\n```\n" .. table.concat(lines, "\n") .. "\n```"
				vim.fn.setreg("+", result)
				print("Copied function (" .. #lines .. " lines)")
				return
			end
		end
		function_node = function_node:parent()
	end
	print("No function found at cursor")
end, { desc = "Copy entire function with reference", silent = false })

-- Copy symbol path (e.g., attribute.String, pkg.Function)
map("n", "<leader>ys", function()
	local current_node = vim.treesitter.get_node()
	if not current_node then
		print("No treesitter node found")
		return
	end

	-- Selector/qualified expression types that represent dotted paths
	local selector_types = {
		"selector_expression", -- Go: attribute.String
		"qualified_identifier", -- Go: pkg.Type
		"member_expression", -- JS/TS: obj.prop
		"field_expression", -- Rust: struct.field
		"attribute", -- Python: obj.attr
		"scoped_identifier", -- Rust: mod::item
	}

	-- Walk up to find the outermost selector/qualified expression
	local node = current_node
	local selector_node = nil

	while node do
		local node_type = node:type()
		for _, sel_type in ipairs(selector_types) do
			if node_type == sel_type then
				selector_node = node
				break
			end
		end
		node = node:parent()
	end

	-- If we found a selector expression, copy the whole thing
	if selector_node then
		local result = vim.treesitter.get_node_text(selector_node, 0)
		-- Clean up any whitespace/newlines
		result = result:gsub("%s+", "")
		vim.fn.setreg("+", result)
		print("Copied: " .. result)
		return
	end

	-- Fallback: just copy the identifier at cursor
	local identifier_types = {
		"identifier",
		"property_identifier",
		"field_identifier",
		"type_identifier",
	}

	local node_type = current_node:type()
	for _, id_type in ipairs(identifier_types) do
		if node_type == id_type then
			local result = vim.treesitter.get_node_text(current_node, 0)
			vim.fn.setreg("+", result)
			print("Copied: " .. result)
			return
		end
	end

	print("No symbol found at cursor")
end, { desc = "Copy symbol path", silent = false })

-- Copy git blame for current line
map("n", "<leader>yb", function()
	local file_path = vim.fn.expand("%:p")
	local line_num = vim.fn.line(".")
	local blame = vim.fn.system(string.format("git blame -L %d,%d --porcelain %s 2>/dev/null", line_num, line_num, file_path))

	if vim.v.shell_error ~= 0 then
		print("Not in a git repository or file not tracked")
		return
	end

	local author, date, summary
	for line in blame:gmatch("[^\n]+") do
		if line:match("^author ") then
			author = line:gsub("^author ", "")
		elseif line:match("^author%-time ") then
			local timestamp = tonumber(line:gsub("^author%-time ", ""))
			date = os.date("%Y-%m-%d", timestamp)
		elseif line:match("^summary ") then
			summary = line:gsub("^summary ", "")
		end
	end

	local rel_path = vim.fn.expand("%:~:.")
	local result = string.format("%s:%d\nAuthor: %s\nDate: %s\nCommit: %s", rel_path, line_num, author or "unknown", date or "unknown", summary or "unknown")
	vim.fn.setreg("+", result)
	print("Copied blame info")
end, { desc = "Copy git blame for line", silent = false })

-- Copy LSP hover information
map("n", "<leader>yh", function()
	local params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, _, _)
		if err or not result or not result.contents then
			print("No hover information available")
			return
		end

		local content
		if type(result.contents) == "string" then
			content = result.contents
		elseif type(result.contents) == "table" then
			if result.contents.value then
				content = result.contents.value
			elseif result.contents.kind then
				content = result.contents.value or vim.inspect(result.contents)
			else
				local parts = {}
				for _, item in ipairs(result.contents) do
					if type(item) == "string" then
						table.insert(parts, item)
					elseif item.value then
						table.insert(parts, item.value)
					end
				end
				content = table.concat(parts, "\n")
			end
		end

		local file_path = vim.fn.expand("%:~:.")
		local line_num = vim.fn.line(".")
		local full_result = file_path .. ":" .. line_num .. "\n" .. content
		vim.fn.setreg("+", full_result)
		print("Copied hover info")
	end)
end, { desc = "Copy LSP hover info", silent = false })

-- Copy quickfix list
map("n", "<leader>yq", function()
	local qf_list = vim.fn.getqflist()
	if #qf_list == 0 then
		print("Quickfix list is empty")
		return
	end

	local lines = { "Quickfix list:" }
	for _, item in ipairs(qf_list) do
		local filename = item.bufnr > 0 and vim.fn.bufname(item.bufnr) or item.filename or ""
		local line_info = ""
		if item.lnum > 0 then
			line_info = ":" .. item.lnum
			if item.col > 0 then
				line_info = line_info .. ":" .. item.col
			end
		end
		local text = item.text or ""
		table.insert(lines, string.format("  %s%s: %s", filename, line_info, text))
	end

	local result = table.concat(lines, "\n")
	vim.fn.setreg("+", result)
	print("Copied " .. #qf_list .. " quickfix item(s)")
end, { desc = "Copy quickfix list", silent = false })

-- Create splits
map("n", "<leader>\\", "<cmd>vnew<cr>", { desc = "Vertical Split", silent = true })
map("n", "<leader>-", "<cmd>new<cr>", { desc = "Horizontal Split", silent = true })

-- Resize splits with alt+cursor keys
map({ "n", "i", "v" }, "<A-j>", "<nop>", { desc = "Disabled" })
map({ "n", "i", "v" }, "<A-k>", "<nop>", { desc = "Disabled" })
map({ "n", "i", "v" }, "<M-j>", "<nop>", { desc = "Disabled" })
map({ "n", "i", "v" }, "<M-k>", "<nop>", { desc = "Disabled" })

map("n", "<M-Up>", ":resize +2<CR>", { desc = "Resize split: increase height" })
map("n", "<M-Down>", ":resize -2<CR>", { desc = "Resize split: decrease height" })
map("n", "<M-Left>", ":vertical resize -2<CR>", { desc = "Resize split: decrease width" })
map("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "Resize split: increase width" })

-- Fun
map("n", "<leader>ca", function()
	require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular Automaton: Make It Rain" })

map("n", "<leader>ct", "<cmd>CloakToggle<CR>", { desc = "Toggle Cloak (secret masking)" })

map("n", "<leader>so", function()
	vim.cmd("so")
end, { desc = "Reload current file" })

-- Comments
-- if vim.env.TMUX ~= nil then
-- 	api.nvim_set_keymap("n", "<C-_>", "gtc", { noremap = false })
-- 	api.nvim_set_keymap("v", "<C-_>", "goc", { noremap = false })
-- else
-- 	api.nvim_set_keymap("n", "<C-/>", "gtc", { noremap = false })
-- 	api.nvim_set_keymap("v", "<C-/>", "goc", { noremap = false })
-- end
