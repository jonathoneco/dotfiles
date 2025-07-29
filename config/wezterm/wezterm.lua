local wezterm = require("wezterm")
local theme = wezterm.plugin.require('https://github.com/neapsix/wezterm').main
local theme = require('lua/rose-pine').main

return {
  -- Appearance
  colors = theme.colors(),
  font = wezterm.font("FiraCode Nerd Font Mono"),
  font_size = 12.0,

  -- Background settings
  window_background_opacity = 0.85,
  macos_window_background_blur = 20, -- Use blur if you want translucent effect on macOS
  window_background_image_hsb = {
    brightness = 1.0,
    hue = 1.0,
    saturation = 1.0,
  },

  -- Copy behavior
  copy_on_select = true,
  quick_select_alphabet = "jfkdls;ahgurieowpq",

  -- Titlebar settings
  window_decorations = "RESIZE",
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  -- macOS-specific
  window_close_confirmation = "NeverPrompt", -- confirm-close-surface = false

  -- Enable sixel for image previews
  enable_sixel = true,

  -- Optional scroll keys (like ctrl-d/u in tmux)
  keys = {
    {
      key = "d",
      mods = "CTRL",
      action = wezterm.action.ScrollByPage(0.5),
    },
    {
      key = "u",
      mods = "CTRL",
      action = wezterm.action.ScrollByPage(-0.5),
    },
  },
}

