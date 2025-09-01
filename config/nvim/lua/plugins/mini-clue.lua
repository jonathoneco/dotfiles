return {
    {
        'echasnovski/mini.clue',
        version = false, -- Use latest commit instead of stable
        enabled = true,
        event = 'VimEnter',
        config = function()
            local miniclue = require('mini.clue')
            miniclue.setup({
                triggers = {
                    -- Leader triggers
                    -- { mode = 'n', keys = '<Leader>' },
                    -- { mode = 'x', keys = '<Leader>' },

                    -- Built-in completion
                    -- { mode = 'i', keys = '<C-x>' },

                    -- `g` key
                    -- { mode = 'n', keys = 'g' },
                    -- { mode = 'x', keys = 'g' },

                    -- Marks
                    { mode = 'n', keys = "'" },
                    { mode = 'n', keys = '`' },
                    { mode = 'x', keys = "'" },
                    { mode = 'x', keys = '`' },

                    -- Registers
                    { mode = 'n', keys = '"' },
                    { mode = 'x', keys = '"' },
                    { mode = 'i', keys = '<C-r>' },
                    { mode = 'c', keys = '<C-r>' },

                    -- Window commands
                    -- { mode = 'n', keys = '<C-w>' },

                    -- `z` key
                    -- { mode = 'n', keys = 'z' },
                    -- { mode = 'x', keys = 'z' },
                },

                clues = {
                    -- Enhance this by adding descriptions for <Leader> mapping groups
                    miniclue.gen_clues.builtin_completion(),
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),

                    -- Custom leader key groups
                    { mode = 'n', keys = '<Leader>a', desc = '+[A]i' },
                    { mode = 'n', keys = '<Leader>g', desc = '+[G]it' },
                    { mode = 'n', keys = '<Leader>s', desc = '+[S]earch' },
                    { mode = 'n', keys = '<Leader>v', desc = '+LSP Actions' },
                    { mode = 'n', keys = '<Leader>c', desc = '+Fun' },
                    { mode = 'n', keys = '<Leader>e', desc = '+Error Snippets' },
                    { mode = 'n', keys = '<Leader>t', desc = '+[T]ests' },
                    { mode = 'n', keys = '<Leader>d', desc = '+[D]ebug' },
                },

                window = {
                    delay = 20,
                    config = {
                        width = 'auto',
                        border = 'rounded',
                    },
                },
            })
        end,
    },
}
