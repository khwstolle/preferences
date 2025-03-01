-- https://wezfurlong.org/wezterm/

local wezterm = require "wezterm"
local config = wezterm.config_builder()

config:set_strict_mode(true)

-- Utilities
local function get_appearance()
    -- First check the COLOR_THEME environment variable
    if os.getenv("COLOR_THEME") then
        return os.getenv("COLOR_THEME")
    end
    -- Second check `wezterm.gui` (not available to the mux server)
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    -- Fallback to dark mode
    return "Dark"
end


-- OS specific configuration
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local is_light = get_appearance():lower() == "light"

if is_windows then
    -- Windows-specific configurations
    config.default_prog       = { "pwsh.exe", "-NoLogo" }
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
else
    -- Assuming a Unix-like environment
    config.integrated_title_button_style = "Gnome"
    config.window_decorations = "NONE"
    config.default_prog = { "/usr/bin/bash", "-l", "-i" }
end

-- Appearance
-- "iTerm2 Tango Dark" or "iTerm2 Tango Light"
local themeName
if is_light then
    themeName = "iTerm2 Tango Light"
else
    themeName = "Catppuccin Mocha"
end
local theme = wezterm.color.get_builtin_schemes()[themeName]

-- Specific adjustments
if themeName == "Catppuccin Mocha" then
    -- theme.background = "#13131F"
end
--
-- Aspecific adjustments
if is_light then
    config.window_background_opacity = 1.0
    -- config.foreground_text_hsb = {
    --     hue = 1.0,
    --     saturation = 1.2,
    --     brightness = 0.8,
    -- }
else
    if is_windows then
        config.win32_system_backdrop = "Mica"
        config.window_background_opacity = 0.2
        theme.background = "#000000"
    else
        --config.window_background_opacity = 0.85
        --theme.background = "#010101"
    end
    -- config.foreground_text_hsb = {
    --     hue = 1.0,
    --     saturation = 1.2,
    --     brightness = 1.5,
    -- }
    --
    --theme.tab_bar = {
    --    background = theme.background,
    --    inactive_tab_edge = 'rgba(28, 28, 28, 0.9)',
    --    active_tab = {
    --        bg_color = theme.background,
    --        fg_color = '#c0c0c0',
    --    },
    --    inactive_tab = {
    --        bg_color = theme.background,
    --        fg_color = '#808080',
    --    },
    --    inactive_tab_hover = {
    --        bg_color = theme.background,
    --        fg_color = '#808080',
    --    },
    --}
end
config.command_palette_font_size    = 11.0
config.color_schemes                = {
    ["User"] = theme
}
config.color_scheme                 = 'User'

-- Misc
config.enable_wayland            = true
--config.canonicalize_pasted_newlines               = 'None'
config.term                      = 'wezterm'
-- config.font                      = wezterm.font_with_fallback({
    -- wezterm.font({ "JetBrainsMono Nerd Font", { weight = 500 } }),
    -- "Noto Color Emoji",
-- })
config.font_size                 = 10.0
config.default_cursor_style      = "BlinkingBar"
config.freetype_load_target      = "Light"

-- Support KITTY features
config.enable_kitty_graphics     = true
--config.enable_kitty_keyboard                      = true
config.window_close_confirmation    = "NeverPrompt"
config.enable_tab_bar               = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar            = true

-- Launch menu
config.launch_menu                  = {
    {
        label = "System monitor", -- create side-by-side monitoring with nvtop and htop
        args = { "nvtop" },

    },
    {
        label = "Tmux",
        args = { "tmux", "new-session", "-A", "-s", "wezterm" },
    }
}

-- Rendering
local function find_gpu(spec)
    for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
        if gpu.backend:find(spec.backend) and gpu.device_type:find(spec.device_type) then
            return gpu
        end
    end
    return nil
end

--  INTEGRATED_GPU = { backend = "Vulkan", device_type = "IntegratedGpu" }
--  DISCRETE_GPU = { backend = "Vulkan", device_type = "DiscreteGpu" }
--
--  for _, spec in ipairs { INTEGRATED_GPU, DISCRETE_GPU } do
--      local gpu = find_gpu(spec)
--      if gpu then
--          config.webgpu_preferred_adapter = gpu
--          break
--      end
--  end
-- config.webgpu_power_preference = "LowPower"
--config.max_fps = 60
--config.front_end = "WebGpu"
--config.animation_fps = 1
--config.cursor_blink_ease_in = 'Constant'
--config.cursor_blink_ease_out = 'Constant'

-- Plugins
local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.apply_to_config(config)

local wezterm = require('wezterm')
local wezterm_config_nvim = wezterm.plugin.require('https://github.com/winter-again/wezterm-config.nvim')
wezterm.on('user-var-changed', function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    overrides = wezterm_config_nvim.override_user_var(overrides, name, value)
    window:set_config_overrides(overrides)
end)

--Bindings
config.mouse_bindings = {
    {
        event = { Down = { streak = 3, button = "Left" } },
        action = wezterm.action.SelectTextAtMouseCursor "SemanticZone",
        mods = "NONE",
    },
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ""
            if has_selection then
                window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
                window:perform_action(wezterm.action.ClearSelection, pane)
            else
                window:perform_action(wezterm.action({ PasteFrom = "Clipboard" }), pane)
            end
        end),
    },
}

config.leader = { key = "b", mods = "CTRL" }
config.disable_default_key_bindings = true
config.keys = {
    -- Passthrough double LEADER (CTRL-B)
    { key = config.leader.key, mods = "LEADER|CTRL",  action = wezterm.action.SendString("\x02") },
    -- Copy/Paste
    { key = "c",               mods = "CTRL|SHIFT",   action = wezterm.action.CopyTo "Clipboard" },
    { key = "v",               mods = "CTRL|SHIFT",   action = wezterm.action.PasteFrom "Clipboard" },
    -- Show launcher
    { key = "c",               mods = "LEADER|CTRL",  action = wezterm.action.ShowLauncherArgs { flags = "LAUNCH_MENU_ITEMS|DOMAINS|WORKSPACES", } },
    -- Show tab switcher
    { key = "Tab",             mods = "LEADER",       action = wezterm.action.ShowTabNavigator },
    -- Show command palette
    { key = "Space",           mods = "LEADER",       action = wezterm.action.ActivateCommandPalette },
    -- Tmux-like Keybindings
    -- https://gist.github.com/quangIO/556fa4abca46faf40092282d0c11a367
    { key = "\"",              mods = "LEADER|SHIFT", action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "%",               mods = "LEADER|SHIFT", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
    { key = "z",               mods = "LEADER",       action = "TogglePaneZoomState" },
    { key = "c",               mods = "LEADER",       action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
    { key = "h",               mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Left" } },
    { key = "j",               mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Down" } },
    { key = "k",               mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Up" } },
    { key = "l",               mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Right" } },
    { key = "H",               mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Left", 5 } } },
    { key = "J",               mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Down", 5 } } },
    { key = "K",               mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Up", 5 } } },
    { key = "L",               mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Right", 5 } } },
    { key = "1",               mods = "LEADER",       action = wezterm.action { ActivateTab = 0 } },
    { key = "2",               mods = "LEADER",       action = wezterm.action { ActivateTab = 1 } },
    { key = "3",               mods = "LEADER",       action = wezterm.action { ActivateTab = 2 } },
    { key = "4",               mods = "LEADER",       action = wezterm.action { ActivateTab = 3 } },
    { key = "5",               mods = "LEADER",       action = wezterm.action { ActivateTab = 4 } },
    { key = "6",               mods = "LEADER",       action = wezterm.action { ActivateTab = 5 } },
    { key = "7",               mods = "LEADER",       action = wezterm.action { ActivateTab = 6 } },
    { key = "8",               mods = "LEADER",       action = wezterm.action { ActivateTab = 7 } },
    { key = "9",               mods = "LEADER",       action = wezterm.action { ActivateTab = 8 } },
    { key = "&",               mods = "LEADER|SHIFT", action = wezterm.action { CloseCurrentTab = { confirm = true } } },
    { key = "x",               mods = "LEADER",       action = wezterm.action { CloseCurrentPane = { confirm = true } } },
}



return config
