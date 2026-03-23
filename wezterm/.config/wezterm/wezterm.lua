-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 128
config.initial_rows = 32

config.enable_tab_bar = false

-- or, changing the font size and color scheme.
config.font_size = 14
config.font = wezterm.font ('JetBrainsMonoNL Nerd Font Mono', {weight="Regular", stretch="Normal", style="Normal"})
config.color_scheme = 'rose-pine-moon'
config.color_scheme_dirs = {'./colors/'}

-- Finally, return the configuration to wezterm:
return config
