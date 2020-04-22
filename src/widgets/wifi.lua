local awful = require("awful")
local wibox = require('wibox')
local vicious = require('vicious')

local utils = require('utils')

local function render(widget, args)
  local ssid = args["{ssid}"]
  local strength = args["{linp}"]
  widget.tooltip.text = "SSID: " .. ssid .. "\n" .. "Strength: " .. strength .. "%"
  if ssid then
    return "wifi " .. utils.pips_of_pct(strength)
  else
    return ""
  end
end

return function (config, props)
  local widget = wibox.widget.textbox()
  widget.tooltip = awful.tooltip { objects={widget} }

  widget:buttons(
    awful.util.table.join(
      awful.button({ }, 1, props.openWifiManager)
    )
  )

  vicious.register(widget, vicious.widgets.wifi, render, 3, "wlo1")

  return widget
end
