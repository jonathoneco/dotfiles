# Maintain Neovim

Use Neovim 0.12 or newer. Run `:Lazy restore` to use the plugin versions in
`lazy-lock.json`. To update plugins, run `:Lazy update`, run the checks below,
and commit the changed lockfile. Treesitter's build hook runs `:TSUpdate` to
keep parsers compatible with its queries.

Mise provides Prettier for Markdown formatting and Stylua for Lua formatting.
Run `mise install` after applying changes to the tool list.

Mason installs language servers. Server settings use `vim.lsp.config` before
Mason enables them. Mason v2 does not run the older `handlers` configuration.

Markdown files use the nearest `.marksman.toml` or Git project as their
workspace. A `.git` directory at your home directory does not make scratch
notes index your whole home. Those notes use Marksman's single-file support.
An explicit `~/.marksman.toml` allows a home-wide workspace.

Treesitter maps parser names to Neovim filetypes, including `bash` to `sh`.
Files larger than 100 KB use the default highlighting and indentation.
HTML keeps its existing syntax highlighting.

## Check a change

With plugins, Prettier, and the Mason Marksman package installed, run from the checkout:

```sh
python3 tests/nvim-config.py
./validate.sh
```

The regression check opens disposable files through the full configuration.
It checks Markdown workspace selection, completion capabilities, Lua settings,
and parser activation. It stores logs in a temporary directory and uses the
installed plugins. Run `:checkhealth config` in Neovim for runtime prerequisites.
