local wibox = require('wibox')

local widget = wibox.widget {
  orientation = "vertical",
  forced_width = 10,
}

function widget.times(factor)
  return wibox.widget {
    orientation = "vertical",
    forced_width = (factor or 1) * 10,
  }
end

return widget
