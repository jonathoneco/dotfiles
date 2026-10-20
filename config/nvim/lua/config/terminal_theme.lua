local ansi = { "red", "green", "yellow", "blue", "purple", "cyan" }
local tint_chroma = 8

local function apply(colors)
    local convert = require("mini.colors").convert
    local hues = require("mini.hues")
    local palette = hues.make_palette({ background = colors.bg, foreground = colors.fg })
    local bg_l, fg_l = convert(colors.bg, "oklch").l, convert(colors.fg, "oklch").l

    local lch = {}
    for _, name in ipairs(ansi) do
        lch[name] = convert(colors[name], "oklch")
        palette[name] = colors[name]
        palette[name .. "_bg"] = convert({ l = bg_l, c = tint_chroma, h = lch[name].h }, "hex")
    end
    for name, pair in pairs({ orange = { "red", "yellow" }, azure = { "cyan", "blue" } }) do
        local a, b = lch[pair[1]], lch[pair[2]]
        local h = a.h + ((b.h - a.h + 540) % 360 - 180) / 2
        palette[name] = convert({ l = fg_l, c = (a.c + b.c) / 2, h = h }, "hex")
        palette[name .. "_bg"] = convert({ l = bg_l, c = tint_chroma, h = h }, "hex")
    end

    hues.apply_palette(palette)
    local surface = {}
    for _, shade in ipairs({ "bg", "bg_edge", "bg_edge2" }) do
        surface[palette[shade]:lower()] = true
    end
    local function is_transparent_surface(name, bg)
        return bg and (surface[bg] or (name:match("^Pmenu") and bg == palette.bg_mid:lower()))
    end
    for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        local bg = hl.bg and string.format("#%06x", hl.bg)
        if is_transparent_surface(name, bg) then
            hl.bg = nil
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
    vim.g.terminal_bg = colors.bg
    vim.g.colors_name = "terminal"
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "terminal", modeline = false })
end

return { apply = apply }
