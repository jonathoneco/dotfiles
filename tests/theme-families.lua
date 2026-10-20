local root = vim.env.THEME_TEST_ROOT
vim.opt.runtimepath:prepend(root .. "/config/nvim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.local/share/nvim/lazy/mini.nvim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.local/share/nvim/lazy/lualine.nvim")
local native = vim.env.EVERFOREST_TEST_PATH or (vim.env.HOME .. "/.local/share/nvim/lazy/everforest")
vim.opt.runtimepath:append(native)
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
print("PASS native palettes, semantic highlights, transparency, statusline, complete replies, fallback, and timeout")
vim.cmd.qa()
