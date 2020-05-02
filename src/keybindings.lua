local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local shift = "Shift"
local ctrl = "Control"
local esc = "Escape"
local tab = "Tab"
local space = "space"
local ret = "Return"

function len(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

local function next_tag()
  local current_tag = awful.screen.focused().selected_tag
  local tag_count = len(awful.screen.focused().tags)
  if current_tag.index < tag_count then
    awful.tag.viewnext()
  end
end

local function prev_tag()
  local current_tag = awful.screen.focused().selected_tag
  if current_tag.index > 1 then
    awful.tag.viewprev()
  end
end

function cycle_layouts()
  awful.layout.inc(1)
end

local function show_minimized()
  local c = awful.client.restore()
  -- Focus restored client
  if c then
    client.focus = c
    c:raise()
  end
end

local function minimize_client(c)
  -- The client currently has the input focus, so it cannot be
  -- minimized, since minimized clients can't have the focus.
  c.minimized = true
end

function next_client()
  awful.client.focus.byidx(1)
end

function prev_client()
  awful.client.focus.byidx(-1)
end

local function swap_client_next()
  awful.client.swap.byidx(1)
end

function swap_client_prev()
  awful.client.swap.byidx(-1)
end

function focus_screen_next()
  awful.screen.focus_relative(1)
end

function focus_screen_prev()
  awful.screen.focus_relative(-1)
end

function kill_client(c)
  c:kill()
end

function focus_client(c)
  c:swap(awful.client.getmaster())
end

function toggle_client_fullscreen(c)
  c.fullscreen = not c.fullscreen
  c:raise()
end

function increase_master_width()
  awful.tag.incmwfact( 0.05)
end

function decrease_master_width()
  awful.tag.incmwfact(-0.05)
end

function more_in_master()
  awful.tag.incnmaster(1, nil, true)
end

function fewer_in_master()
  awful.tag.incnmaster(-1, nil, true)
end

function more_columns()
  awful.tag.incncol(1, nil, true)
end

function fewer_columns()
  awful.tag.incncol(-1, nil, true)
end

return function (config, props)
  local mod = config.modkey

  local global = gears.table.join(
    awful.key({ mod }, space, props.openLauncher, {
        description = "show launcher", group = "launcher"
    }),

    awful.key({ mod }, "s", hotkeys_popup.show_help, {
        description="show help", group="awesome"
    }),

    awful.key({ mod }, "&", props.toggle_theme, {
        description = "toggle theme", group = "awesome"
    }),

    awful.key({ mod }, ",", prev_tag, {
        description = "view previous", group = "tag"
    }),

    awful.key({ mod }, ".", next_tag, {
        description = "view next", group = "tag"
    }),

    -- Layout manipulation

    awful.key({ mod, shift }, space, cycle_layouts, {
        description = "select next", group = "layout"
    }),

    awful.key({ mod, ctrl }, "m", show_minimized, {
        description = "restore minimized", group = "client"
    }),

    awful.key({ mod }, "j", next_client, {
        description = "focus next by index", group = "client"
    }),

    awful.key({ mod }, tab, next_client, {
        description = "focus next by index", group = "client"
    }),

    awful.key({ mod }, "k", prev_client, {
        description = "focus previous by index", group = "client"
    }),

    awful.key({ mod, shift }, tab, prev_client, {
        description = "focus previous by index", group = "client"
    }),

    awful.key({ mod, shift }, "m", swap_client_next, {
        description = "swap with next client by index", group = "client"
    }),

    awful.key({ mod, shift }, "w", swap_client_prev, {
        description = "swap with previous client by index", group = "client"
    }),

    awful.key({ mod, ctrl }, "j", focus_screen_next, {
        description = "focus the next screen", group = "screen"
    }),

    awful.key({ mod, ctrl }, "k", focus_screen_prev, {
        description = "focus the previous screen", group = "screen"
    }),

    awful.key({ mod }, "u", awful.client.urgent.jumpto, {
        description = "jump to urgent client", group = "client"
    }),

    awful.key({ mod }, "l", increase_master_width, {
        description = "increase master width factor", group = "layout"
    }),

    awful.key({ mod }, "h", decrease_master_width, {
        description = "decrease master width factor", group = "layout"
    }),

    awful.key({ mod, shift }, "h", more_in_master, {
        description = "increase the number of master clients", group = "layout"
    }),

    awful.key({ mod, shift }, "l", fewer_in_master, {
        description = "decrease the number of master clients", group = "layout"
    }),

    awful.key({ mod, ctrl }, "h", more_columns, {
        description = "increase the number of columns", group = "layout"
    }),

    awful.key({ mod, ctrl }, "l", fewer_columns, {
        description = "decrease the number of columns", group = "layout"
    }),

    -- Standard programs

    awful.key({ mod }, "e", props.openEditor, {
        description = "open an editor", group = "launcher"
    }),

    awful.key({ mod }, "f", props.openFSBrowser, {
        description = "open a filesystem window", group = "launcher"
    }),

    awful.key({ mod }, "d", props.openTerminal, {
        description = "open a terminal", group = "launcher"
    }),


    -- Function keys

    awful.key({}, "XF86TouchpadToggle", props.services.keyboard.toggle_layout),
    awful.key({}, "XF86AudioRaiseVolume", props.services.volume.up),
    awful.key({}, "XF86AudioLowerVolume", props.services.volume.down),
    awful.key({}, "XF86AudioMute", props.services.volume.toggle),

    awful.key({}, "XF86MonBrightnessUp", props.services.brightness.up),
    awful.key({}, "XF86MonBrightnessDown", props.services.brightness.down),

    awful.key({mod}, "F1", props.prevSong),
    awful.key({mod}, "F2", props.playPauseSong),
    awful.key({mod}, "F3", props.nextSong),

    -- Session management

    awful.key({ mod, ctrl }, "r", awesome.restart, {
        description = "reload awesome", group = "awesome"
    }),

    awful.key({ mod, shift }, "q", awesome.quit, {
        description = "quit awesome", group = "awesome"
    })
  )

  local client = gears.table.join(
    awful.key({ mod }, "q", kill_client, {
        description = "close", group = "client"
    }),

    awful.key({ mod, ctrl }, space, awful.client.floating.toggle, {
        description = "toggle floating", group = "client"
    }),

    awful.key({ mod }, ret, focus_client, {
        description = "move to master", group = "client"
    }),

    awful.key({ mod, shift }, ret, toggle_client_fullscreen, {
        description = "toggle fullscreen", group = "client"
    }),

    awful.key({ mod }, "m", minimize_client, {
        description = "minimize", group = "client"
    })
  )

  local keybindings = { global = global, client = client }

  function keybindings.install()
    root.keys(keybindings.global)
  end

  return keybindings
end
