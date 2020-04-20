local awful = require("awful")
local helpers = require("vicious.helpers")

function init_widget(config)
  return helpers.setasyncall{
    async = function (format, warg, callback)
      awful.spawn.easy_async_with_shell(
        config.xbacklight_path .. " -get",
        function(stdout)
          local trimmed = stdout.gsub(stdout, '[ \t\n\r]', '')
          local value = math.floor(0.5 + tonumber(trimmed))
          callback({ ["{value}"] = value })
      end)
  end }
end

return init_widget
