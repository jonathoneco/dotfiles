-- Generic init.lua that detects OS and loads appropriate config

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- Detect OS and set config path
local function get_os_config()
  local handle = io.popen("uname -s")
  if handle then
    local result = handle:read("*a"):gsub("%s+", "")
    handle:close()
    
    if result == "Darwin" then
      return "os.mac"
    elseif result == "Linux" then
      return "os.ubuntu"
    end
  end
  
  -- Fallback to macOS config
  print("⚠️  Unknown OS, falling back to macOS config")
  return "os.mac"
end

-- Load OS-specific configuration
local os_config = get_os_config()
require(os_config .. '.init')

-- vim: ts=2 sts=2 sw=2 et