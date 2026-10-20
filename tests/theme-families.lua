local root = vim.env.THEME_TEST_ROOT
vim.opt.runtimepath:prepend(root .. "/config/nvim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.local/share/nvim/lazy/mini.nvim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.local/share/nvim/lazy/lualine.nvim")
local native = vim.env.EVERFOREST_TEST_PATH or (vim.env.HOME .. "/.local/share/nvim/lazy/everforest")
vim.opt.runtimepath:append(native)
local shadow = vim.fn.tempname()
vim.fn.mkdir(shadow .. "/colors", "p")
vim.fn.writefile({ "error('generic builtin Catppuccin must not supply the native status line')" }, shadow .. "/colors/catppuccin.lua")
vim.opt.runtimepath:prepend(shadow)
local catalog = {}
for _, path in ipairs(vim.fn.glob(root .. "/config/theme-families/*.json", false, true)) do
    local entry = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
    catalog[entry.id] = entry
    if entry.id ~= "everforest" then
        vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/" .. entry.id)
    end
end
vim.opt.termguicolors = true
local family = vim.json.decode(table.concat(vim.fn.readfile(root .. "/config/theme-families/everforest.json"), "\n"))
local themes = require("config.theme_families")
local notifications, events = {}, 0
vim.notify = function(message) notifications[#notifications + 1] = message end
vim.api.nvim_create_autocmd("User", { pattern = "ThemeApplied", callback = function() events = events + 1 end })
local query_count = 0
vim.api.nvim_ui_send = function() query_count = query_count + 1 end
local function response(sequence)
    vim.api.nvim_exec_autocmds("TermResponse", { data = { sequence = sequence } })
end
local function rgb(hex)
    return hex:sub(2, 3):rep(2) .. "/" .. hex:sub(4, 5):rep(2) .. "/" .. hex:sub(6, 7):rep(2)
end
local function send(p)
    themes.refresh(false)
    themes.refresh(false)
    local before = events
    response("\027[?1;2c")
    response("\027]4;99;rgb:ffff/ffff/ffff\027\\")
    response("\027]10;rgb:invalid\027\\")
    response("\027]11;rgb:" .. rgb(p.background) .. "\027\\")
    for slot = 6, 1, -1 do
        response("\027]4;" .. slot .. ";rgb:" .. rgb(p.ansi[slot+1]) .. "\027\\")
    end
    assert(events == before, "theme applied before the foreground arrived")
    response("\027]10;rgb:" .. rgb(p.foreground) .. "\027\\")
end
for _, case in ipairs({
    { "dark-hard", "dark", 0xd3c6aa, 0xe67e80, "#7fbbb3", "#a7c080" },
    { "light-medium", "light", 0x5c6a72, 0xf85552, "#3a94c5", "#93b259" },
    { "dark-hard", "dark", 0xd3c6aa, 0xe67e80, "#7fbbb3", "#a7c080" },
}) do
    local variant = family.variants[case[1]]
    send(variant.terminal)
    assert(vim.g.colors_name == "everforest", "native colorscheme did not apply")
    assert(vim.o.background == case[2])
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    assert(normal.fg == case[3] and normal.bg == nil, "native foreground/transparency mismatch")
    assert(vim.api.nvim_get_hl(0, { name = "Statement", link = false }).fg == case[4])
    assert(vim.api.nvim_get_hl(0, { name = "DiagnosticError", link = false }).fg == case[4])
    assert(vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg == nil)
    local palette = vim.fn["everforest#get_palette"](variant.native_options.contrast, vim.empty_dict())
    assert(variant.terminal.background == palette.bg0[1], "catalog background differs from native palette")
    assert(variant.terminal.foreground == palette.fg[1])
    for slot = 0, 15 do
        assert(variant.terminal.ansi[slot+1] == vim.g["terminal_color_" .. slot], "native ANSI mismatch at " .. slot)
    end
    local status = themes.statusline_theme()
    assert(status.normal.a.bg == case[6], "native lualine mode color missing: " .. case[1] .. " actual=" .. tostring(status.normal.a.bg) .. " expected=" .. case[6])
    assert(status.normal.b.bg == "None" and status.normal.c.bg == "None")
    assert(vim.g.terminal_color_4 == case[5])
end
assert(query_count == 3, "overlapping focus events sent duplicate queries")
local before = events
send(family.variants["dark-hard"].terminal)
assert(events == before, "unchanged palette reapplied")
local unknown = vim.deepcopy(family.variants["dark-hard"].terminal)
unknown.ansi[2] = "#112233"
send(unknown)
assert(vim.g.colors_name == "terminal", "unknown palette was mislabeled as native")
assert(vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg ~= nil)
assert(#notifications == 1 and notifications[1]:find("unrecognized", 1, true))
themes.refresh(false)
response("\027]11;rgb:ffff/ffff/ffff\027\\")
vim.wait(2200, function() return #notifications == 2 end, 20)
assert(vim.g.colors_name == "terminal" and notifications[2]:find("did not report all", 1, true))
vim.opt.runtimepath:remove(native)
local before_missing = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
send(family.variants["light-medium"].terminal)
assert(vim.g.colors_name == "terminal", "missing native plugin changed the current scheme")
assert(vim.deep_equal(before_missing, vim.api.nvim_get_hl(0, { name = "Normal", link = false })))
assert(#notifications == 3 and notifications[3]:find("native plugin is not installed", 1, true))
vim.opt.runtimepath:append(native)
local cases = {
    { "tokyonight", "night", "tokyonight-night", "#bb9af7", "#db4b4b", "#7aa2f7", "#15161e" },
    { "catppuccin", "latte", "catppuccin-latte", "#8839ef", "#d20f39", "#1e66f5", "#e6e9ef" },
    { "rose-pine", "main", "rose-pine", "#31748f", "#eb6f92", "#ebbcba", "#191724" },
    { "kanagawa", "lotus", "kanagawa", "#624c83", "#e82424", "#4d699b", "#d5cea3" },
    { "catppuccin", "mocha", "catppuccin-mocha", "#cba6f7", "#f38ba8", "#89b4fa", "#181825" },
    { "tokyonight", "day", "tokyonight-day", "#9854f1", "#c64343", "#2e7de9", "#b4b5b9" },
    { "kanagawa", "dragon", "kanagawa", "#8992a7", "#e82424", "#8ba4b0", "#0d0c0c" },
    { "rose-pine", "dawn", "rose-pine", "#286983", "#b4637a", "#d7827e", "#faf4ed" },
    { "catppuccin", "frappe", "catppuccin-frappe", "#ca9ee6", "#e78284", "#8caaee", "#292c3c" },
    { "tokyonight", "moon", "tokyonight-moon", "#c099ff", "#c53b53", "#82aaff", "#1b1d2b" },
    { "rose-pine", "moon", "rose-pine", "#3e8fb0", "#eb6f92", "#ea9a97", "#232136" },
    { "kanagawa", "wave", "kanagawa", "#957fb8", "#e82424", "#7e9cd8", "#16161d" },
    { "tokyonight", "storm", "tokyonight-storm", "#bb9af7", "#db4b4b", "#7aa2f7", "#1d202f" },
    { "catppuccin", "macchiato", "catppuccin-macchiato", "#c6a0f6", "#ed8796", "#8aadf4", "#1e2030" },
    { "everforest", "light-medium", "everforest", "#f85552", "#f85552", "#93b259", "#fdf6e3" },
    { "everforest", "dark-hard", "everforest", "#e67e80", "#e67e80", "#a7c080", "#272e33" },
    { "gruvbox", "dark", "gruvbox", "#fb4934", "#fb4934", "#458588", "#282828" },
    { "gruvbox", "light", "gruvbox", "#9d0006", "#9d0006", "#458588", "#fbf1c7" },
    { "nightfox", "carbonfox", "carbonfox", "#be95ff", "#ee5396", "#78a9ff", "#0c0c0c" },
    { "nightfox", "dawnfox", "dawnfox", "#907aa9", "#b4637a", "#286983", "#ebe5df" },
    { "nightfox", "dayfox", "dayfox", "#6e33ce", "#a5222f", "#2848a9", "#e4dcd4" },
    { "nightfox", "duskfox", "duskfox", "#c4a7e7", "#eb6f92", "#569fba", "#191726" },
    { "nightfox", "nightfox", "nightfox", "#9d79d6", "#c94f6d", "#719cd6", "#131a24" },
    { "nightfox", "nordfox", "nordfox", "#b48ead", "#bf616a", "#81a1c1", "#232831" },
    { "nightfox", "terafox", "terafox", "#ad5c7c", "#e85c51", "#5a93aa", "#0f1c1e" },
    { "onedark", "dark", "onedark", "#c678dd", "#e86671", "#98c379", "#282c34" },
    { "github", "light-default", "github_light_default", "#cf222e", "#d1242f", "#0969da", "#ffffff" },
    { "onedark", "darker", "onedark", "#bf68d9", "#e55561", "#8ebd6b", "#1f2329" },
    { "github", "dark-default", "github_dark_default", "#ff7b72", "#f85149", "#58a6ff", "#0d1117" },
    { "onedark", "light", "onedark", "#a626a4", "#e45649", "#50a14f", "#fafafa" },
    { "github", "dark-dimmed", "github_dark_dimmed", "#f47067", "#e5534b", "#539bf5", "#22272e" },
    { "nord", "dark", "nord", "#81a1c1", "#bf616a", "#81a1c1", "#2e3440" },
    { "solarized", "light", "solarized", "#859900", "#dc322f", "#268bd2", "#fdf6e3" },
    { "dracula", "dark", "dracula", "#ff79c6", "#ff5555", "#bd93f9", "#282a36" },
    { "solarized", "dark", "solarized", "#859900", "#dc322f", "#268bd2", "#002b36" },
}
local covered = {}
for pass = 1, 2 do
    for offset = 1, #cases do
        local case = cases[pass == 1 and offset or (#cases - offset + 1)]
        local entry = catalog[case[1]]
        local variant = entry.variants[case[2]]
        covered[case[1] .. "/" .. case[2]] = true
        send(variant.terminal)
        assert(vim.g.colors_name == case[3], case[1] .. "/" .. case[2] .. ": native scheme did not apply")
        assert(vim.o.background == variant.appearance)
        local function foreground(group)
            return vim.api.nvim_get_hl(0, { name = group, link = false }).fg
        end
        assert(foreground("Normal") == tonumber(variant.terminal.foreground:sub(2), 16))
        assert(foreground("Statement") == tonumber(case[4]:sub(2), 16), case[1] .. ": native syntax mismatch")
        assert(foreground("DiagnosticError") == tonumber(case[5]:sub(2), 16), case[1] .. ": native diagnostic mismatch")
        assert(vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg == nil)
        assert(vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg == nil)
        local status = themes.statusline_theme()
        assert(status.normal.a.bg:lower() == case[6], case[1] .. "/" .. case[2] .. ": native status-line background mismatch")
        assert(status.normal.a.fg:lower() == case[7], case[1] .. "/" .. case[2] .. ": native status-line foreground mismatch")
        assert(status.normal.b.bg == "None" and status.normal.c.bg == "None")
        for slot = 0, 15 do
            assert(vim.g["terminal_color_" .. slot]:lower() == variant.terminal.ansi[slot+1])
        end
    end
end
for id, entry in pairs(catalog) do
    for variant in pairs(entry.variants) do
        assert(covered[id .. "/" .. variant], "missing integration case for " .. id .. "/" .. variant)
    end
    local output = vim.fn.system({ "nvim", "--headless", "-u", "NONE", "-l", root .. "/scripts/theme-native.lua", id })
    assert(vim.v.shell_error == 0, output)
end
assert(#notifications == 3, "unexpected errors while switching native themes: " .. vim.inspect(notifications))
vim.fn.delete(shadow, "rf")
print("PASS all native variants, cross-family changes, pinned palette snapshots, semantic highlights, statusline, transparency, protocol, fallback, and timeout")
vim.cmd.qa()
