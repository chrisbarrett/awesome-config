local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local menubar = require("menubar")
local wibox = require("wibox")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local utils = require('utils')

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.max,
}

local function orgfile(name)
  return os.getenv("HOME") .. "/Dropbox/org/" .. name .. ".org"
end

return function (config)
  local hooks = {
    brightness_changed = {},
    keyboard_changed = {},
    volume_changed = {},
  }

  local props = require('props')(config, hooks)
  props.volume_service = require('services.volume')(config)

  config.org_files = {
    orgfile("personal"),
    orgfile("personal_recurring"),
  }

  local theme = require('theme')(config)
  beautiful.init(theme)

  client.connect_signal("focus", function(c) c.border_color = theme.border_focus end)
  client.connect_signal("unfocus", function(c) c.border_color = theme.border_normal end)

  local volume = require('widgets.volume')(config, props)

  table.insert(
    hooks.volume_changed,
    function()
      volume:update()
    end
  )

  local brightness = require("widgets.brightness")(config, props)

  table.insert(
    hooks.brightness_changed,
    function()
      brightness:update()
    end
  )

  local keyboard = require("widgets.keyboard")(config, props)

  table.insert(
    hooks.keyboard_changed,
    function (value)
      keyboard:update(value)
    end
  )

  local keybindings = require('keybindings')(config, props)
  root.keys(keybindings.global)
  awful.rules.rules = require('rules')(config, keybindings)


  -- Menu

  -- Create a wibox for each screen and add it

  local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ config.modkey }, 1, function(t)
        if client.focus then
          client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ config.modkey }, 3, function(t)
        if client.focus then
          client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
  )

  local function client_menu_toggle_fn()
    local instance = nil

    return function ()
      if instance and instance.wibox.visible then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients { theme = { width = 250 } }
      end
    end
  end

  local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
          c.minimized = true
        else
          -- Without this, the following
          -- :isvisible() makes no sense
          c.minimized = false
          if not c:isvisible() and c.first_tag then
            c.first_tag:view_only()
          end
          -- This will also un-minimize
          -- the client, if needed
          client.focus = c
          c:raise()
        end
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
  end))

  local function set_wallpaper(s)
    gears.wallpaper.maximized(config.desktop_picture, s, true)
  end

  -- Reapply wallpaper when a screen's geometry changes (e.g. different resolution)
  screen.connect_signal("property::geometry", set_wallpaper)


  local has_battery = os.execute("upower -e | grep -i battery")

  local battery = has_battery and require("widgets.battery") {
    widget_text = "${color_on}${AC_BAT}${color_off}",
    ac_prefix = {
      { 30,  " ·   " },
      { 50,  " ··  " },
      { 80,  " ··· " },
      { 100, " FULL" },
    },
    battery_prefix = {
      { 5,   "" },
      { 25,  "" },
      { 50,  "" },
      { 75,  "" },
      { 100, "" },
    },
    percent_colors = {
      { 25, "red" },
      { 35, "orange" },
      { 999, "white" },
    },
  }

  local org_todos = require('widgets.org_todos')(config, props)
  local wifi = require('widgets.wifi')(config, props)

  local padding = require('widgets.padding')

  awful.screen.connect_for_each_screen(function(s)
      set_wallpaper(s)

      local wibar = awful.wibar { position = "top", screen = s }

      wibar:setup {
        layout = wibox.layout.align.horizontal,
        {
          layout = wibox.layout.fixed.horizontal,
          awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = taglist_buttons,
          },
          padding.times(3),
        },
        awful.widget.tasklist {
          screen = s,
          filter = awful.widget.tasklist.filter.currenttags,
          buttons = tasklist_buttons,
        },
        {
          layout = wibox.layout.fixed.horizontal,
          padding,
          padding,
          mail,
          org_todos,
          padding,
          volume,
          padding,
          brightness,
          wifi and padding,
          wifi,
          keyboard,
          battery and padding.times(2),
          battery,
          battery and padding,
          wibox.widget.textclock(),
        },
      }
  end)
end
