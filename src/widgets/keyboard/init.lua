local awful = require("awful")
local helpers = require("vicious.helpers")

function init_widget(config)
  return helpers.setasyncall{
    async = function (format, warg, callback)
      awful.spawn.easy_async_with_shell(
        config.read_layout_command,
        function(stdout)
          local trimmed = stdout.gsub(stdout, '[ \t\n\r]', '')
          local args = { ["{layout}"] = trimmed }
          callback(args)
      end)
  end }
end

return init_widget
