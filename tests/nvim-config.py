#!/usr/bin/env python3
"""Exercise the checkout's Neovim config with installed plugins and disposable files.

Run with python3 tests/nvim-config.py. Neovim and the Mason Marksman package
must already be installed. Logs and the simulated home stay in a temp directory.
"""

import os
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))

CHECK = r'''
local failures = {}
local function check(condition, message)
    print((condition and "PASS " or "FAIL ") .. message)
    if not condition then table.insert(failures, message) end
end

check(vim.v.errmsg == "", "configuration loads without startup errors: " .. vim.v.errmsg)

local home = vim.env.HOME
local function open_markdown(path, expected_root, label)
    vim.cmd("silent! %bwipeout!")
    vim.cmd.edit(vim.fn.fnameescape(path))
    local attached = vim.wait(10000, function()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "marksman" })) do
            if client.initialized then return true end
        end
        return false
    end, 20)
    local client = vim.lsp.get_clients({ bufnr = 0, name = "marksman" })[1]
    check(attached and client ~= nil, label .. ": Marksman attaches")
    if client then
        check(client.config.root_dir == expected_root,
            label .. ": workspace = " .. tostring(expected_root)
                .. " (actual " .. tostring(client.config.root_dir) .. ")")
        if expected_root == nil then
            check(client.workspace_folders == nil, label .. ": no workspace folders are sent")
        end
        if label == "home note" then
            vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# Saved note", "", "Updated text." })
            vim.cmd.write()
            check(vim.fn.readfile(path)[3] == "Updated text.", "saving writes the edited Markdown")
            check(not vim.fn.execute("messages"):find("client.supports_method is deprecated", 1, true),
                "saving uses the current LSP client API")
        end
        client:stop()
        vim.wait(2000, function() return client:is_stopped() end, 20)
    end
end

open_markdown(home .. "/scratch.md", nil, "home note")
open_markdown(home .. "/project/README.md", home .. "/project", "Git project")
open_markdown(home .. "/notes/sub/note.md", home .. "/notes", "Marksman project")
open_markdown(home .. "/outside/note.md", nil, "note outside a project")

vim.fn.writefile({}, home .. "/.marksman.toml")
open_markdown(home .. "/scratch.md", home, "explicit home workspace")

local capabilities = vim.lsp.config.lua_ls.capabilities
check(capabilities and capabilities.textDocument.completion.completionItem.snippetSupport == true,
    "language servers advertise snippet completion")
local lua = vim.lsp.config.lua_ls.settings
check(lua and lua.Lua and lua.Lua.format and lua.Lua.format.defaultConfig.indent_size == "2",
    "Lua formatting settings apply")
check(not vim.list_contains(vim.lsp.config.tailwindcss.filetypes, "markdown"),
    "Tailwind stays off Markdown")

for _, case in ipairs({
    { "example.sh", "program" },
    { "example.txt", "help_file" },
}) do
    vim.cmd("silent! %bwipeout!")
    vim.cmd.edit(vim.fn.fnameescape(home .. "/" .. case[1]))
    if case[1] == "example.txt" then vim.bo.filetype = "help" end
    local highlighter = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
    check(highlighter ~= nil, vim.bo.filetype .. ": Treesitter highlighting starts")
    check(vim.bo.indentexpr == "v:lua.require'nvim-treesitter'.indentexpr()",
        vim.bo.filetype .. ": Treesitter indentation starts")
    if highlighter then
        local tree = vim.treesitter.get_parser():parse()[1]
        check(tree:root():type() == case[2], vim.bo.filetype .. ": parser reads the buffer")
    end
end

vim.cmd("silent! %bwipeout!")
vim.cmd.edit(vim.fn.fnameescape(home .. "/large.lua"))
check(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] == nil,
    "large files keep syntax highlighting")
check(vim.bo.indentexpr == "GetLuaIndent()", "large Lua files keep default indentation")

vim.cmd(#failures == 0 and "qa!" or "cquit 1")
'''


def main():
    with tempfile.TemporaryDirectory(prefix="nvim-config-") as temporary:
        fixture = Path(temporary)
        home = fixture / "home"
        for directory in [".git", "project/.git", "notes/sub", "outside"]:
            (home / directory).mkdir(parents=True)
        for name in ["scratch.md", "project/README.md", "notes/sub/note.md", "outside/note.md"]:
            (home / name).write_text("# Example\n\nSome text.\n")
        (home / "notes/.marksman.toml").write_text("")
        (home / "example.sh").write_text("printf '%s\\n' hello\n")
        (home / "example.txt").write_text("A help document\n")
        (home / "large.lua").write_text("-- Example\n" * 12000)
        script = fixture / "check.lua"
        script.write_text(CHECK)
        environment = dict(os.environ)
        environment.update(
            HOME=str(home),
            XDG_CONFIG_HOME=str(ROOT / "config"),
            XDG_DATA_HOME=str(DATA_HOME),
            XDG_STATE_HOME=str(fixture / "state"),
            XDG_CACHE_HOME=str(fixture / "cache"),
        )
        result = subprocess.run(
            ["nvim", "--headless", "-u", str(ROOT / "config/nvim/init.lua"),
             "-c", "luafile " + str(script)],
            env=environment, cwd=home, timeout=60, check=False,
        )
        return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
