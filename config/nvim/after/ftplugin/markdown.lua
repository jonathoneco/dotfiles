-- Jupyter/Molten configuration for Markdown files (including .ipynb notebooks)
-- This file only runs when editing Markdown files

-- Check if this is likely a notebook (has code cells)
local function is_notebook()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
    for _, line in ipairs(lines) do
        if line:match("^```{python") or line:match("^```python") then
            return true
        end
    end
    return false
end

-- Only set up notebook features if this looks like a notebook
if is_notebook() then
    -- Activate quarto for LSP features in code cells
    local quarto_ok, quarto = pcall(require, "quarto")
    if quarto_ok then
        quarto.activate()
    end

    local function molten_initialized()
        local kernels = vim.fn["MoltenAvailableKernels"]()
        return kernels and #kernels > 0
    end

    -- Initialize Molten with default kernel if not already initialized
    local function initialize_molten()
        if not molten_initialized() then
            vim.cmd("MoltenInit python3")
        end
    end

    -- Keymaps for Molten (only for notebook markdown files)
    local opts = { buffer = true, silent = true }

    -- Evaluate operator (e.g., <localleader>e + motion)
    vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Evaluate operator" }))

    -- Run line
    vim.keymap.set("n", "<localleader>rl", ":MoltenEvaluateLine<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Evaluate line" }))

    -- Run visual selection
    vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", vim.tbl_extend("force", opts, { desc = "Molten: Evaluate visual selection" }))

    -- Re-evaluate cell
    vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Re-evaluate cell" }))

    -- Delete cell
    vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Delete cell" }))

    -- Show output window
    vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Show output" }))

    -- Hide output
    vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Hide output" }))

    -- Open output in browser (for HTML outputs)
    vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Open in browser" }))

    -- Initialize molten
    vim.keymap.set("n", "<localleader>mi", initialize_molten, vim.tbl_extend("force", opts, { desc = "Molten: Initialize" }))

    -- Interrupt kernel
    vim.keymap.set("n", "<localleader>mq", ":MoltenInterrupt<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Interrupt kernel" }))

    -- Show kernel status
    vim.keymap.set("n", "<localleader>ms", ":MoltenStatus<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Show status" }))
end
