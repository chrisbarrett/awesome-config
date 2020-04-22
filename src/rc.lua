require("./error_handlers")

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local menubar = require("menubar")
local naughty = require("naughty")
local vicious = require('vicious')
local wibox = require("wibox")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local make_theme = require('theme')
local utils = require('./utils')

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.max,
}

local function orgfile(name)
  return os.getenv("HOME") .. "/Dropbox/org/" .. name .. ".org"
end

-- Prevent clients from being unreachable after screen count changes.
client.connect_signal(
  "manage",
  function (c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_offscreen(c)
    end
  end
)


return function (config)
  config.org_files = {
    orgfile("personal"),
    orgfile("personal_recurring"),
  }

  local theme = make_theme(config)
  beautiful.init(theme)

  client.connect_signal(
    "focus",
    function(c)
      c.border_color = theme.border_focus
    end
  )

  client.connect_signal(
    "unfocus",
    function(c)
      c.border_color = theme.border_normal
    end
  )



  -- Variable definitions

  -- Functions to inject to other modules.

  local on_brightness_change
  local on_keyboard_change
  local volume

  local props = {
    brightnessUp = function ()
      awful.spawn.easy_async_with_shell(
        config.xbacklight_path .. " -inc 10%",
        on_brightness_change
      )
    end,
    brightnessDown = function ()
      awful.spawn.easy_async_with_shell(
        config.xbacklight_path .. " -dec 10%",
        on_brightness_change
      )
    end,
    openEditor = function ()
      awful.spawn(config.editor_command)
    end,
    openFSBrowser = function ()
      awful.spawn(config.fs_browser)
    end,
    openTerminal = function ()
      awful.spawn(config.terminal_command)
    end,
    openLauncher = function()
      awful.spawn(config.launcher_command)
    end,
    volumeUp = function()
      volume:unmute()
      volume:up()
    end,
    volumeDown = function()
      volume:unmute()
      volume:down()
    end,
    toggleMute = function()
      volume:toggle()
    end,
    openWifiManager = function ()
      awful.spawn(config.wifi_manager_command)
    end,
    setKeyboardLayoutDvorak = function ()
      awful.spawn.easy_async_with_shell(config.set_keyboard_dvorak, on_keyboard_change)
    end,
    setKeyboardLayoutQwerty = function ()
      awful.spawn.easy_async_with_shell(config.set_keyboard_qwerty, on_keyboard_change)
    end,
    toggleKeyboardLayout = function ()
      awful.spawn.easy_async_with_shell(config.toggle_keyboard_command, on_keyboard_change)
    end,
    prevSong = function()
      awful.spawn("sp prev")
    end,
    playPauseSong = function()
      awful.spawn("sp play")
    end,
    nextSong = function()
      awful.spawn("sp next")
    end
  }

  volume = require("widgets.volume-control") {
    device = "pulse",
    step = '10%',
    lclick = config.audio_manager_program,
    rclick = "toggle",
    callback = function(self, setting)
      self.widget.text = "vol " .. utils.pips_of_pct(setting.volume, setting.state == "off");
    end
  }

  local brightness = require("widgets.brightness")(config, props)

  local keyboard_layout = require("widgets.keyboard")(config, props)

  on_keyboard_change = function ()
    keyboard_layout.notify()
    vicious.force({ keyboard_layout })
  end

  on_brightness_change = function()
    vicious.force({ brightness })
  end

  local keybindings = require('./keybindings')(config, props)
  root.keys(keybindings.global)
  awful.rules.rules = require('./rules')(config, keybindings)


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
  local wifi =  require('widgets.wifi')(config, props)

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
          volume.widget,
          padding,
          brightness,
          wifi and padding,
          wifi,
          keyboard_layout,
          battery and padding.times(2),
          battery,
          battery and padding,
          wibox.widget.textclock(),
        },
      }
  end)


  -- Make sure we reload the xprofile so that keyboard repeat settings are loaded.
  awful.spawn.with_shell('~/.xprofile')

end
