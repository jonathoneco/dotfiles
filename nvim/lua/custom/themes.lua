local Themes = {}

-- Save in dotfiles config directory
local state_file = vim.g.config_dir .. '/nvim/colorscheme.json'

-- Ensure directory exists
vim.fn.mkdir(vim.fn.fnamemodify(state_file, ':h'), 'p')

-- Blacklist of themes to avoid
local blacklist_file = vim.g.config_dir .. '/nvim/colorscheme_blacklist.json'

local function load_blacklist()
  local f = io.open(blacklist_file, 'r')
  if not f then
    return {}
  end
  local content = f:read '*a'
  f:close()
  local ok, data = pcall(vim.fn.json_decode, content)
  return (ok and data) or {}
end

local function save_blacklist(blacklist)
  local f = io.open(blacklist_file, 'w')
  if f then
    f:write(vim.fn.json_encode(blacklist))
    f:close()
  end
end

function Themes.ColorMyPencils(color)
  color = color or 'kanagawa-wave'
  vim.cmd.colorscheme(color)

  -- Save theme to JSON state file
  local f = io.open(state_file, 'w')
  if f then
    f:write(vim.fn.json_encode { theme = color })
    f:close()
  end
end

function Themes.select_theme()
  local all_themes = vim.fn.getcompletion('', 'color')
  local blacklist = load_blacklist()
  local blacklist_set = {}
  for _, t in ipairs(blacklist) do
    blacklist_set[t] = true
  end

  local themes = vim.tbl_filter(function(theme)
    return not blacklist_set[theme]
  end, all_themes)
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local dropdown = require('telescope.themes').get_dropdown

  pickers
    .new(
      dropdown {
        prompt_title = 'Select Colorscheme',
        width = 0.5,
        results_title = false,
        preview_title = false,
        winblend = 10,
      },
      {
        finder = finders.new_table {
          results = themes,
          entry_maker = function(entry)
            return {
              value = entry,
              display = '🌈 ' .. entry,
              ordinal = entry,
            }
          end,
        },
        sorter = conf.generic_sorter {},
        attach_mappings = function(prompt_bufnr, map)
          local previewed = nil

          local function preview_theme()
            local selection = action_state.get_selected_entry()
            if selection and selection.value ~= previewed then
              vim.cmd.colorscheme(selection.value)
              previewed = selection.value
            end
          end

          map({ 'i', 'n' }, '<Up>', function()
            actions.move_selection_previous(prompt_bufnr)
            preview_theme()
          end)

          map({ 'i', 'n' }, '<Down>', function()
            actions.move_selection_next(prompt_bufnr)
            preview_theme()
          end)

          map('i', '<C-k>', function()
            actions.move_selection_previous(prompt_bufnr)
            preview_theme()
          end)

          map('i', '<C-j>', function()
            actions.move_selection_next(prompt_bufnr)
            preview_theme()
          end)

          map({ 'i', 'n' }, '<C-d>', function()
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end

            local name = selection.value
            table.insert(blacklist, name)
            save_blacklist(blacklist)
            print('❌ Blacklisted: ' .. name)

            actions.close(prompt_bufnr)

            -- Add slight delay before reopening to avoid redraw artifacts
            vim.defer_fn(
              vim.schedule_wrap(function()
                vim.cmd 'redraw' -- Clear floating window artifacts
                Themes.select_theme()
              end),
              120
            )
          end)

          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            Themes.ColorMyPencils(selection.value)
            print('Theme set to: ' .. selection.value)
          end)

          return true
        end,
      }
    )
    :find()
end

function Themes.load_last_theme()
  local f = io.open(state_file, 'r')
  if f then
    local content = f:read '*a'
    f:close()
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and data and data.theme then
      pcall(Themes.ColorMyPencils, data.theme)
    end
  end
end

return Themes
