local awful = require('awful')
local wibox = require('wibox')
local vicious = require('vicious')

local function render(widget, args)
  local overdue = args[1]
  local today = args[2]
  local total = overdue + today
  local tooltip_text = ""

  if today > 0 then
    tooltip_text = tooltip_text ..  "Today:   " .. today .. "\n"
  end

  if overdue > 0 then
    tooltip_text = tooltip_text ..  "Overdue: " .. overdue .. "\n"
  end

  widget.tooltip.text = tooltip_text:match("(.-)%s*$")

  if overdue > 0 then
    return "<span foreground=\"orange\"> " .. total .. "</span>  "
  elseif total > 0 then
    return " " .. total .. "  "
  else
    return ""
  end
end

return function (config, props)
  local widget = wibox.widget.textbox()
  widget.tooltip = awful.tooltip { objects={widget} }
  local success = pcall(vicious.register, widget, vicious.widgets.org, render, 5, config.org_files)
  if success then
    return widget
  end
end
