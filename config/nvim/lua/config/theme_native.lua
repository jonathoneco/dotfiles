local M = {}

function M.hex(color)
    if type(color) == "number" then
        return string.format("#%06x", color)
    end
    assert(type(color) == "string" and color:match("^#%x%x%x%x%x%x$"), "native RGB color is missing")
    return color:lower()
end

function M.color(group, component, fallback)
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    return M.hex(highlight[component] or fallback)
end

function M.pair(group, foreground, background)
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    local pair = { fg = M.hex(highlight.fg or foreground), bg = M.hex(highlight.bg or background) }
    if highlight.reverse then
        pair.fg, pair.bg = pair.bg, pair.fg
    end
    return pair
end

function M.statusline(spec, variant)
    local module = variant.lualine_module or spec.lualine_module
    if type(module) ~= "string" then
        return nil
    end
    local schemes = vim.list_extend(
        vim.api.nvim_get_runtime_file("colors/" .. spec.colorscheme .. ".lua", true),
        vim.api.nvim_get_runtime_file("colors/" .. spec.colorscheme .. ".vim", true)
    )
    for _, scheme in ipairs(schemes) do
        local plugin = vim.fs.dirname(vim.fs.dirname(scheme))
        local path = vim.fs.joinpath(plugin, "lua", module:gsub("%.", "/") .. ".lua")
        if vim.uv.fs_stat(path) then
            return assert(loadfile(path))()
        end
    end
    error("native status-line file is missing: " .. module)
end

function M.accent(spec, variant, fallback)
    local theme = M.statusline(spec, variant)
    local pair = theme and theme.normal.a or fallback
    return { fg = M.hex(pair.fg), bg = M.hex(pair.bg) }
end

return M
