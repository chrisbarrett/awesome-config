local batterywidget = require('battery-widget')

return function (config, props)
  if props.hasBattery() then
    return batterywidget {
      widget_text = "${color_on}${AC_BAT}${color_off}",
      ac_prefix = {
        { 30,  " ·   " },
        { 50,  " ··  " },
        { 80,  " ··· " },
        { 100, " FULL" },
      },
      battery_prefix = {
        { 5,   "" },
        { 25,  "" },
        { 50,  "" },
        { 75,  "" },
        { 100, "" },
      },
      percent_colors = {
        { 25, "red" },
        { 35, "orange" },
        { 999, "white" },
      },
    }
  end
end
