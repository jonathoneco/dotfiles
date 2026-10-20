local M = {}
local ansi = { "red", "green", "yellow", "blue", "purple", "cyan" }
local directory = vim.fs.joinpath(vim.fn.stdpath("config"), "..", "theme-families")
local families, index = {}, {}
local active, applied, pending, applied_colors
local warned_unknown = false

local function key(colors)
    local values = { colors.bg, colors.fg }
    for _, name in ipairs(ansi) do
        values[#values + 1] = colors[name]
    end
    return table.concat(values, " ")
end

for _, path in ipairs(vim.fn.glob(directory .. "/*.json", false, true)) do
    local family = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
    assert(family.schema == 1 and family.id == vim.fn.fnamemodify(path, ":t:r"), "invalid theme family: " .. path)
    families[#families + 1] = family
    for id, variant in pairs(family.variants) do
        local p = variant.terminal
        local colors = { bg = p.background, fg = p.foreground }
        for slot, name in ipairs(ansi) do
            colors[name] = p.ansi[slot + 1]
        end
        local signature = key(colors)
        assert(not index[signature], "duplicate native palette: " .. family.id .. "/" .. id)
        index[signature] = { family = family, variant = variant }
    end
end
assert(#families > 0, "no supported theme families in " .. directory)

local function to_hex(rgb)
    local r, g, b = rgb:match("^(%x+)/(%x+)/(%x+)$")
    if not r then
        return nil
    end
    local result = {}
    for _, channel in ipairs({ r, g, b }) do
        if #channel > 4 then
            return nil
        end
        result[#result + 1] = string.format("%02x", math.floor(tonumber(channel, 16) / (16 ^ #channel - 1) * 255 + .5))
    end
    return "#" .. table.concat(result)
end

local function apply(colors)
    local signature = key(colors)
    if applied == signature then
        return
    end
    local selection = index[signature]
    local previous = active
    local previous_bg = vim.g.terminal_bg
    vim.g.terminal_bg = colors.bg
    active = selection
    local ok, error = pcall(function()
        if selection then
            local scheme = selection.family.native.colorscheme
            assert(vim.fn.globpath(vim.o.runtimepath, "colors/" .. scheme .. ".vim") ~= ""
                or vim.fn.globpath(vim.o.runtimepath, "colors/" .. scheme .. ".lua") ~= "", "native plugin is not installed")
            require("config.theme_families." .. selection.family.id).apply(selection.variant)
        else
            require("config.terminal_theme").apply(colors)
            if not warned_unknown then
                vim.notify("theme: unrecognized terminal palette; using terminal colors", vim.log.levels.INFO)
                warned_unknown = true
            end
        end
    end)
    if not ok then
        active = previous
        if previous then
            require("config.theme_families." .. previous.family.id).apply(previous.variant)
        elseif applied_colors then
            require("config.terminal_theme").apply(applied_colors)
        end
        vim.g.terminal_bg = previous_bg
        vim.notify("theme: native theme could not load; run :Lazy sync. " .. tostring(error), vim.log.levels.ERROR)
        return
    end
    applied, applied_colors = signature, vim.deepcopy(colors)
    vim.api.nvim_exec_autocmds("User", { pattern = "ThemeApplied", modeline = false })
end

function M.statusline_theme()
    local native = active and active.family.native
    local theme = native and require("config.theme_native").statusline(native, active.variant)
    if not theme and native then
        local p = active.variant.terminal
        theme = {}
        for mode, slot in pairs({ normal = 4, insert = 2, visual = 5, replace = 1, command = 3, inactive = 8 }) do
            theme[mode] = {
                a = { fg = p.background, bg = p.ansi[slot + 1] },
                b = { fg = p.foreground, bg = "None" },
                c = { fg = p.foreground, bg = "None" },
            }
        end
    elseif not theme then
        package.loaded["lualine.themes.auto"] = nil
        theme = vim.deepcopy(require("lualine.themes.auto"))
    end
    for _, mode in pairs(theme) do
        for section, colors in pairs(mode) do
            if section ~= "a" then
                colors.bg = "None"
            end
            if not native and colors.fg == "#000000" and vim.g.terminal_bg then
                colors.fg = vim.g.terminal_bg
            end
        end
    end
    return theme
end

function M.refresh(wait)
    if pending then
        return
    end
    local colors, done = {}, false
    local id
    id = vim.api.nvim_create_autocmd("TermResponse", {
        callback = function(ev)
            local sequence = ev.data.sequence
            local code, rgb = sequence:match("^\027%](1[01]);rgb:([%x/]+)")
            if code then
                colors[code == "10" and "fg" or "bg"] = to_hex(rgb)
            end
            local slot, value = sequence:match("^\027%]4;(%d+);rgb:([%x/]+)")
            local name = slot and ansi[tonumber(slot)]
            if name then
                colors[name] = to_hex(value)
            end
            if vim.tbl_count(colors) ~= 8 then
                return
            end
            done, pending = true, nil
            apply(colors)
            return true
        end,
    })
    pending = id
    vim.defer_fn(function()
        if not done then
            done, pending = true, nil
            pcall(vim.api.nvim_del_autocmd, id)
            vim.notify("theme: the terminal did not report all its colors; keeping the current scheme", vim.log.levels.WARN)
        end
    end, 2000)
    local query = "\027]10;?\027\\\027]11;?\027\\"
    for slot = 1, 6 do
        query = query .. "\027]4;" .. slot .. ";?\027\\"
    end
    vim.api.nvim_ui_send(query)
    if wait then
        vim.wait(300, function() return done end, 1)
    end
end

function M.setup()
    local has_tty = vim.iter(vim.api.nvim_list_uis()):any(function(ui) return ui.stdout_tty end)
    if not has_tty then
        return
    end
    M.refresh(true)
    vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("terminal_theme", { clear = true }),
        callback = function() M.refresh(false) end,
        desc = "Apply the native theme for the attached terminal palette",
    })
    vim.api.nvim_create_user_command("ThemeRefresh", function() M.refresh(false) end, {})
end

function M.plugin_specs()
    local dependencies = {}
    for _, family in ipairs(families) do
        dependencies[#dependencies + 1] = { family.native.repository, name = family.id, commit = family.native.commit }
    end
    return { {
        "echasnovski/mini.nvim",
        lazy = false,
        priority = 1000,
        dependencies = dependencies,
        config = M.setup,
    } }
end

return M
