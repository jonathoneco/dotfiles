-- Neovim takes its colors from the terminal, so Ghostty's `theme` line is the
-- one place a theme is chosen. At startup and on focus, Neovim asks the
-- terminal for its background, foreground and ANSI colors 1-6; mini.hues
-- builds the full scheme around them.

local ansi = { "red", "green", "yellow", "blue", "purple", "cyan" } -- ANSI slots 1-6
local tint_chroma = 8 -- mini.hues' "medium" saturation, for the `_bg` tints

-- "rrrr/gggg/bbbb" with 1-4 hex digits per channel -> "#rrggbb"
local function to_hex(rgb)
    local out = {}
    for part in rgb:gmatch("%x+") do
        out[#out + 1] = string.format("%02x", math.floor(tonumber(part, 16) / (16 ^ #part - 1) * 255 + 0.5))
    end
    return #out == 3 and "#" .. table.concat(out) or nil
end

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
    -- The terminal has no orange or azure, so place them halfway around the hue circle.
    for name, pair in pairs({ orange = { "red", "yellow" }, azure = { "cyan", "blue" } }) do
        local a, b = lch[pair[1]], lch[pair[2]]
        local h = a.h + ((b.h - a.h + 540) % 360 - 180) / 2
        palette[name] = convert({ l = fg_l, c = (a.c + b.c) / 2, h = h }, "hex")
        palette[name .. "_bg"] = convert({ l = bg_l, c = tint_chroma, h = h }, "hex")
    end

    hues.apply_palette(palette)
    vim.g.colors_name = "terminal"
end

local applied
-- Ask the terminal for its colors and apply them once all eight replies are
-- in. No DSR/DA1 marks the end: Neovim sends its own at startup, and over SSH
-- its reply can arrive after this autocmd exists.
local function sync(wait)
    local colors, done = {}, false
    local id = vim.api.nvim_create_autocmd("TermResponse", {
        callback = function(ev)
            local seq = ev.data.sequence
            local code, rgb = seq:match("^\027%](1[01]);rgb:([%x/]+)")
            if code then
                colors[code == "10" and "fg" or "bg"] = to_hex(rgb)
            end
            local slot, slot_rgb = seq:match("^\027%]4;(%d);rgb:([%x/]+)")
            if slot then
                colors[ansi[tonumber(slot)]] = to_hex(slot_rgb)
            end
            if vim.tbl_count(colors) < #ansi + 2 then
                return false
            end
            done = true
            if not vim.deep_equal(colors, applied) then
                apply(colors)
                applied = colors
            end
            return true -- delete this autocmd
        end,
    })
    vim.defer_fn(function()
        if not done then
            done = true
            pcall(vim.api.nvim_del_autocmd, id)
            vim.notify("theme: the terminal did not report all its colors; keeping the current scheme", vim.log.levels.WARN)
        end
    end, 2000)
    local query = "\027]10;?\027\\\027]11;?\027\\"
    for slot = 1, #ansi do
        query = query .. "\027]4;" .. slot .. ";?\027\\"
    end
    vim.api.nvim_ui_send(query)
    if wait then
        vim.wait(300, function() return done end, 1)
    end
end

return {
    {
        "echasnovski/mini.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            local has_tty = vim.iter(vim.api.nvim_list_uis()):any(function(ui) return ui.stdout_tty end)
            if not has_tty then
                return
            end
            sync(true)
            vim.api.nvim_create_autocmd("FocusGained", {
                group = vim.api.nvim_create_augroup("terminal_theme", {}),
                callback = function() sync(false) end,
                desc = "Rebuild the colorscheme from the terminal's current colors",
            })
        end,
    },
}
