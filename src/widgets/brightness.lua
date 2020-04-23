local awful = require("awful")
local helpers = require("vicious.helpers")
local vicious = require('vicious')
local wibox = require('wibox')

local utils = require('utils')

local function render(widget, args)
  return "bl " .. utils.pips_of_pct(args.value)
end

return function (config)
  local widget = wibox.widget.textbox()

  function widget:update()
    vicious.force({ brightness })
  end

  local vwidget = helpers.setasyncall {
    async = function (format, warg, callback)
      awful.spawn.easy_async_with_shell(
        config.xbacklight_path .. " -get",
        function(stdout)
          local trimmed = stdout.gsub(stdout, '[ \t\n\r]', '')
          local value = math.floor(0.5 + tonumber(trimmed))
          callback({ value = value })
      end)
  end }

  vicious.register(widget, vwidget, render)

  return widget
end
