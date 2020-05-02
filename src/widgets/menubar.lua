local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local padding = require('widgets.padding')

return function(config, props, widgets)
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

  local widget = {}

  function widget.add_to_screen(s)
    awful.wibar { position = "top", screen = s }:setup {
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
        widgets.mail,
        widgets.org_todos,
        padding,
        widgets.volume,
        padding,
        widgets.brightness,
        widgets.wifi and padding,
        widgets.wifi,
        widgets.keyboard,
        widgets.battery and padding.times(2),
        widgets.battery,
        widgets.battery and padding,
        wibox.widget.textclock(),
      },
    }
  end

  function widget.install()
    awful.screen.connect_for_each_screen(widget.add_to_screen)
  end

  return widget
end
