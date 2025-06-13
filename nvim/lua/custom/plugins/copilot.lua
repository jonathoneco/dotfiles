return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    panel = { enabled = false },
    suggestion = { enabled = false }, -- Avante handles suggestions instead
    filetypes = { ['*'] = true },
  },
}
