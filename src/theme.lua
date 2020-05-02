local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(config)
  local function set_wallpaper(s)
    gears.wallpaper.maximized(config.desktop_picture, s, true)
  end

  local theme = {
    font          = "Ubuntu Mono",
    wallpaper     = config.desktop_picture,

    bg_normal     = "#222222",
    bg_focus      = "#535d6c",
    bg_urgent     = "#ff0000",
    bg_minimize   = "#444444",
    bg_systray    = "#222222",

    fg_normal     = "#aaaaaa",
    fg_focus      = "#ffffff",
    fg_urgent     = "#ffffff",
    fg_minimize   = "#ffffff",

    useless_gap   = dpi(10),
    border_width  = dpi(1),
    border_normal = "#505050",
    border_focus  = "#dfaaaa",
    border_marked = "#91231c",

    -- Variables set for theming notifications:
    -- notification_font
    -- notification_[bg|fg]
    -- notification_[width|height|margin]
    -- notification_[border_color|border_width|shape|opacity]

    menu_height = dpi(15),
    menu_width  = dpi(100),

    -- Define the icon theme for application icons. If not set then the icons
    -- from /usr/share/icons and /usr/share/icons/hicolor will be used.
    icon_theme = nil,

    hotkeys_modifiers_fg = "#a77",
    hotkeys_group_margin = 20,
    tasklist_plain_task_name = true,
  }

  function theme.install()
    beautiful.init(theme)
    client.connect_signal("focus", function(c) c.border_color = theme.border_focus end)
    client.connect_signal("unfocus", function(c) c.border_color = theme.border_normal end)

    screen.connect_signal("property::geometry", set_wallpaper)
    awful.screen.connect_for_each_screen(set_wallpaper)
  end

  return theme
end
