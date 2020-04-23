local awful = require('awful')
local helpers = require("vicious.helpers")
local vicious = require('vicious')
local wibox = require('wibox')
local naughty = require('naughty')

local utils = require('utils')

local function render(widget, args)
  local pips = utils.pips_of_pct(args.volume, args.muted)
  local text = "vol " .. pips
  widget.text = text
end

return function (config, props)
  local widget = wibox.widget.textbox()

  function widget:update(state)
    props.currentVolume(function(args)
        vicious.force({ volume })
        render(widget, args)
    end)
  end

  widget:buttons(
    awful.util.table.join(
      awful.button({ }, 1, props.openAudioManager)
    )
  )

  local vwidget = helpers.setasyncall {
    async = function (format, warg, callback)
      props.currentVolume(function(args)
          callback(args)
      end)
    end
  }

  vicious.register( widget, vwidget, render, 7)

  return widget
end
