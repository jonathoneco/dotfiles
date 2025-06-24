local Themes = {}

-- Save in Neovim's data directory: ~/.local/share/nvim/colorscheme.json (or similar)
local state_file = vim.fn.stdpath('data') .. '/colorscheme.json'

-- Ensure directory exists
vim.fn.mkdir(vim.fn.fnamemodify(state_file, ':h'), 'p')

function Themes.ColorMyPencils(color)
  color = color or 'kanagawa-wave'
  vim.cmd.colorscheme(color)

  -- Save theme to JSON state file
  local f = io.open(state_file, 'w')
  if f then
    f:write(vim.fn.json_encode({ theme = color }))
    f:close()
  end
end

function Themes.select_theme()
  local themes = vim.fn.getcompletion('', 'color')

  vim.ui.select(themes, {
    prompt = 'Select a colorscheme:',
    format_item = function(item)
      return "🌈 " .. item
    end,
  }, function(choice)
    if choice then
      Themes.ColorMyPencils(choice)
      print("Theme set to: " .. choice)
    end
  end)
end

function Themes.load_last_theme()
  local f = io.open(state_file, 'r')
  if f then
    local content = f:read('*a')
    f:close()
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and data and data.theme then
      pcall(Themes.ColorMyPencils, data.theme)
    end
  end
end

return Themes

