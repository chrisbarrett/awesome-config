local awful = require("awful")
local helpers = require("vicious.helpers")
local vicious = require('vicious')
local naughty = require('naughty')
local wibox = require('wibox')

local notification

local layouts = {
  ['us(dvp)'] = 'walrus-dvorak',
  ['us'] = 'QWERTY',
}

local function render(widget, args)
  local layout = layouts[args["{layout}"]]

  if layout == 'walrus-dvorak' then
    return ''
  else
    return ' <span foreground="black" background="orange"> <b>' .. layout .. '</b> </span>'
  end
end

local function show_notification(layout)
    layout = layouts[layout] or layout

    if notification then
      naughty.destroy(notification)
      notification = nil
    end

    notification = naughty.notify {
      title = 'Keyboard',
      text = "Keyboard layout changed to " .. layout .. "."
    }
end

return function (config, props)
  local widget = wibox.widget.textbox()

  function widget:update(value)
    vicious.force({ self })
    if value then
      show_notification(layout)
    else
      awful.spawn.easy_async_with_shell(
        config.read_layout_command,
        function(stdout)
          local layout = stdout.gsub(stdout, '[ \t\n\r]', '')
          show_notification(layout)
        end
      )
    end
  end

  widget:buttons(
    awful.util.table.join(
      awful.button({ }, 1, props.toggleKeyboardLayout)
    )
  )

  local vwidget = helpers.setasyncall {
    async = function (format, warg, callback)
      awful.spawn.easy_async_with_shell(
        config.read_layout_command,
        function(stdout)
          local trimmed = stdout.gsub(stdout, '[ \t\n\r]', '')
          local args = { ["{layout}"] = trimmed }
          callback(args)
      end)
    end
  }

  vicious.register(widget, vwidget, render, 13)

  return widget
end
