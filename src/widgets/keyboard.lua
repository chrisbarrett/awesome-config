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

local function format_keyboard(widget, args)
  local layout = layouts[args["{layout}"]]

  if layout == 'walrus-dvorak' then
    return ''
  else
    return ' <span foreground="black" background="orange"> <b>' .. layout .. '</b> </span>'
  end
end

function init_widget(config, props)
  local widget = wibox.widget.textbox()

  widget.notify = function()
    awful.spawn.easy_async_with_shell(
      config.read_layout_command,
      function(stdout)
        local layout = stdout.gsub(stdout, '[ \t\n\r]', '')
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
    )
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

  vicious.register(widget, vwidget, format_keyboard)

  return widget
end

return init_widget
