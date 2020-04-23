local awful = require("awful")
local helpers = require("vicious.helpers")
local vicious = require('vicious')
local wibox = require('wibox')

local utils = require('utils')

local function render(widget, args)
  widget.text = "bl " .. utils.pips_of_pct(args.value)
end

return function (config, props)
  local widget = wibox.widget.textbox()

  function widget:update()
    props.currentBrightness(function (value)
        vicious.force({ brightness })
        render(self, { value = value })
    end)
  end

  local vwidget = helpers.setasyncall {
    async = function (format, warg, callback)
      props.currentBrightness(function (value)
          callback { value = value }
      end)
    end
  }

  vicious.register(widget, vwidget, render, 13)

  return widget
end
