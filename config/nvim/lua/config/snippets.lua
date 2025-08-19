local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

-- Helper functions
local function date()
    return os.date("%Y-%m-%d")
end

local function filename()
    return vim.fn.expand("%:t:r")
end

-- Configure LuaSnip settings
ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
})

-- Key mappings for snippet navigation (within expanded snippets)
vim.keymap.set({ "i", "s" }, "<C-j>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-k>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, { silent = true })

vim.keymap.set("i", "<C-l>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)

-- Go snippets
ls.add_snippets("go", {
    s("pkgm", {
        t("package main"),
    }),
    s("iferr", {
        t({ "if err != nil {", "\t" }),
        i(1, "return err"),
        t({ "", "}" }),
    }),
    s("fmain", {
        t({ "func main() {", "\t" }),
        i(1),
        t({ "", "}" }),
    }),
    s("ff", {
        t("func "),
        i(1, "name"),
        t("("),
        i(2),
        t(") "),
        i(3, "error"),
        t({ " {", "\t" }),
        i(4),
        t({ "", "}" }),
    }),
    s("struct", {
        t("type "),
        i(1, "Name"),
        t({ " struct {", "\t" }),
        i(2),
        t({ "", "}" }),
    }),
    s("interface", {
        t("type "),
        i(1, "Name"),
        t({ " interface {", "\t" }),
        i(2),
        t({ "", "}" }),
    }),
    s("for", {
        t("for "),
        i(1, "i := 0; i < len; i++"),
        t({ " {", "\t" }),
        i(2),
        t({ "", "}" }),
    }),
    s("forr", {
        t("for "),
        i(1, "key, value"),
        t(" := range "),
        i(2, "slice"),
        t({ " {", "\t" }),
        i(3),
        t({ "", "}" }),
    }),
})
