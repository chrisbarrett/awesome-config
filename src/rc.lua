return function(config)

require("./error_handlers")

local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local menubar = require("menubar")
local naughty = require("naughty")
local vicious = require('vicious')
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local theme = require('./theme')(config)
beautiful.init(theme)

-- Prevent clients from being unreachable after screen count changes.
client.connect_signal(
  "manage",
  function (c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_offscreen(c)
    end
end)

client.connect_signal(
  "focus",
  function(c)
    c.border_color = theme.border_focus
end)

client.connect_signal(
  "unfocus",
  function(c)
    c.border_color = theme.border_normal
end)



-- Variable definitions

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.max,
}

local function pips_of_pct(number, disabled)
  if number == 0 or disabled then return "off "
  elseif number <= 25 then return "·";
  elseif number <= 50 then return "··";
  elseif number <= 75 then return "···";
  else return "····";
  end
end

local volume = require("widgets.volume-control") {
  device="pulse",
  step = '10%',
  lclick = "pavucontrol",
  rclick = "toggle",
  callback = function(self, setting)
    self.widget.text = "vol " .. pips_of_pct(setting.volume, setting.state == "off");
  end
}

local brightness = require("widgets.brightness") {
  step = '10%',
  callback = function(self, brightness)
    self.widget.text = "bl " .. pips_of_pct(brightness);
  end
}

local keyboard_layout_widget = wibox.widget.textbox()
local keyboard_vicious_widget = require("./widgets/keyboard")(config)

local keyboard_layout_name_mapping = {
  ['us(dvp)'] = 'walrus-dvorak',
  ['us'] = 'QWERTY',
}

local function keyboard_layout_name(raw_layout)
  return keyboard_layout_name_mapping[raw_layout] or raw_layout
end

local keyboard_notification

local function on_keyboard_change ()
  awful.spawn.easy_async_with_shell(
    config.read_layout_command,
    function(stdout)
      local layout = stdout.gsub(stdout, '[ \t\n\r]', '')

      vicious.force({ keyboard_layout_widget })

      if keyboard_notification then
        naughty.destroy(keyboard_notification)
        keyboard_notification = nil
      end

      keyboard_notification = naughty.notify({
          title = 'Keyboard',
          text = "Keyboard layout changed to " .. keyboard_layout_name(layout) .. "."
      })
    end
  )
end


-- Functions to inject to other modules.

local props = {
  brightnessUp = function ()
    brightness:up()
  end,
  brightnessDown = function ()
    brightness:down()
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
    awful.util.spawn(config.launcher_command)
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
    awful.util.spawn("sp prev")
  end,
  playPauseSong = function()
    awful.util.spawn("sp play")
  end,
  nextSong = function()
    awful.util.spawn("sp next")
  end
}

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

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local battery = require("widgets.battery") {
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

local mail = wibox.widget.textbox()

local function format_mail(widget, args)
  local new = args[1]
  local unread = args[2]
  local total = new + unread

  if total > 0 then
    return " " .. total .. "  "
  else
    return ""
  end
end

local function set_up_mail(args)
  local maildir = os.getenv("HOME") .. "/Maildir/walrus/Inbox"
  vicious.register(mail, vicious.widgets.mdir, format_mail, 7, { maildir })
end

pcall(set_up_mail)

local org = wibox.widget.textbox()
org.tooltip = awful.tooltip { objects={org} }

local function format_org(widget, args)
  local overdue = args[1]
  local today = args[2]
  local total = overdue + today
  local tooltip_text = ""

  if today > 0 then
    tooltip_text = tooltip_text ..  "Today:   " .. today .. "\n"
  end

  if overdue > 0 then
    tooltip_text = tooltip_text ..  "Overdue: " .. overdue .. "\n"
  end

  widget.tooltip.text = tooltip_text:match("(.-)%s*$")

  if overdue > 0 then
    return "<span foreground=\"orange\"> " .. total .. "</span>  "
  elseif total > 0 then
    return " " .. total .. "  "
  else
    return ""
  end
end

local function configure_org_widget()
  local function orgfile(name)
    return os.getenv("HOME") .. "/Dropbox/org/" .. name .. ".org"
  end

  local agenda_files = {orgfile("personal"), orgfile("personal_recurring")}

  vicious.register(org, vicious.widgets.org, format_org, 5, agenda_files)
  return agenda_files
end

local has_org_files = pcall(configure_org_widget)

local wifi = wibox.widget.textbox()

wifi:buttons(
  awful.util.table.join(
    awful.button({ }, 1, props.openWifiManager)
  )
)

wifi.tooltip = awful.tooltip { objects={wifi} }

local function format_wifi(widget, args)
  local ssid = args["{ssid}"]
  local strength = args["{linp}"]
  widget.tooltip.text = "SSID: " .. ssid .. "\n" .. "Strength: " .. strength .. "%"
  if ssid then
    return "wifi " .. pips_of_pct(strength)
  else
    return ""
  end
end

vicious.register(wifi, vicious.widgets.wifi, format_wifi, 3, "wlo1")

local clock = wibox.widget.textclock()

local has_wifi = os.execute("cat /proc/net/wireless")
local has_battery = os.execute("upower -e | grep -i battery")


keyboard_layout_widget:buttons(
  awful.util.table.join(
    awful.button({ }, 1, props.toggleKeyboardLayout)
  )
)

local function format_keyboard(widget, args)
  local layout = keyboard_layout_name(args["{layout}"])
  if layout == 'walrus-dvorak' then
    return ''
  else
    return ' <span foreground="black" background="orange"> <b>' .. layout .. '</b> </span>'
  end
end

vicious.register(keyboard_layout_widget, keyboard_vicious_widget, format_keyboard)


local function padding(factor)
  return wibox.widget {
    orientation = "vertical",
    forced_width = (factor or 1) * 10,
  }
end

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
        padding(3),
      },
      awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
      },
      {
        layout = wibox.layout.fixed.horizontal,
        padding(),
        padding(),
        mail,
        has_org_files and org,
        padding(),
        volume.widget,
        padding(),
        brightness.widget,
        has_wifi and padding(),
        has_wifi and wifi,
        keyboard_layout_widget,
        has_battery and padding(2),
        has_battery and battery,
        has_battery and padding(),
        clock,
      },
    }
end)


-- Make sure we reload the xprofile so that keyboard repeat settings are loaded.
awful.spawn.with_shell('~/.xprofile')

end
