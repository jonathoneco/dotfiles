vim.env.PATH = vim.fn.expand("~/.local/share/mise/shims") .. ":" .. vim.env.PATH

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.helpers")
require("config.health")

local spec = {
    { import = "plugins" },
}

local opts = {
    defaults = {
        lazy = true,
    },
    install = {
        colorscheme = { "tokyonight", "habamax" },
    },
    rtp = {
        disabled_plugins = {
            "gzip",
            "matchit",
            "matchparen",
            "netrw",
            "netrwPlugin",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
        },
    },
    change_detection = {
        notify = false,
    },
    checker = {
        enabled = true,
        notify = false,
    },
}

require("lazy").setup(spec, opts)
