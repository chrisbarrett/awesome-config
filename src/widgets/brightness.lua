local helpers = require("vicious.helpers")
local vicious = require('vicious')
local wibox = require('wibox')

local utils = require('utils')

local function render(widget, state)
  local pips = utils.pips_of_pct(state.brightness)
  local text = "bl " .. pips
  widget.text = text
end

return function (config, props)
  local widget = wibox.widget.textbox()
  local service = props.services.brightness

  service:add_change_hook(function (state)
    vicious.force({ widget })
    render(widget, state)
  end)

  local vwidget = helpers.setasyncall {
    async = function (format, warg, callback)
      service.state(callback)
    end
  }

  vicious.register(widget, vwidget, render, 13)

  return widget
end
