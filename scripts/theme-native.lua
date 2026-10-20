local root = vim.env.THEME_TEST_ROOT or vim.fn.getcwd()
local id = assert(arg[1], "usage: nvim --headless -u NONE -l scripts/theme-native.lua <family> [--write]")
local path = root .. "/config/theme-families/" .. id .. ".json"
local family = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
local plugin = vim.env.THEME_PLUGIN_DIR or (vim.fn.stdpath("data") .. "/lazy/" .. id)
local commit = vim.fn.system({ "git", "-C", plugin, "rev-parse", "HEAD" }):gsub("%s+$", "")
assert(commit == family.native.commit, "native plugin revision differs from manifest: " .. plugin)
vim.opt.runtimepath:prepend(root .. "/config/nvim")
vim.opt.runtimepath:append(plugin)
vim.opt.termguicolors = true
local adapter = require("config.theme_families." .. id)
for variant_id, variant in pairs(family.variants) do
    adapter.apply(variant)
    local palette = adapter.palette()
    for role, color in pairs(palette) do
        palette[role] = color:lower()
    end
    palette.ansi = {}
    for slot = 0, 15 do
        local color = vim.g["terminal_color_" .. slot]
        assert(type(color) == "string" and color:match("^#%x%x%x%x%x%x$"), "native ANSI color missing: " .. slot)
        palette.ansi[#palette.ansi + 1] = color:lower()
    end
    if arg[2] == "--write" then
        variant.terminal = palette
    else
        assert(vim.deep_equal(variant.terminal, palette), id .. "/" .. variant_id .. ": native palette differs from manifest")
    end
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    assert(normal.fg == tonumber(palette.foreground:sub(2), 16) and normal.bg == nil, "native foreground/transparency mismatch")
    assert(vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg == nil, "native float must be transparent")
    print("PASS " .. id .. "/" .. variant_id .. " native palette and transparency")
end
if arg[2] == "--write" then
    local formatted = vim.fn.system({ "python3", "-c", "import json,sys; print(json.dumps(json.load(sys.stdin), indent=2, sort_keys=True))" }, vim.json.encode(family))
    assert(vim.v.shell_error == 0, "cannot format native manifest")
    vim.fn.writefile(vim.split(formatted:gsub("\n$", ""), "\n"), path)
end
vim.cmd.qa()
