local awful = require("awful")
local helpers = require("vicious.helpers")
local vicious = require('vicious')
local wibox = require('wibox')

function render(widget, state)
  if state.layout == 'dvorak' then
    widget.markup = ''
  else
    widget.markup = ' <span foreground="black" background="orange"> <b>QWERTY</b> </span>'
  end
end

return function (config, props)
  local widget = wibox.widget.textbox()
  local service = props.services.keyboard

  widget:buttons(
    awful.util.table.join(
      awful.button({ }, 1, service.toggle_layout)
    )
  )

  service:add_change_hook(function (state)
      vicious.force { widget }
      render(widget, state)
  end)

  local vwidget = helpers.setasyncall {
    async = function (format, warg, callback)
      service.state(callback)
    end
  }

  vicious.register(widget, vwidget, render, 7)

  return widget
end
