local awful = require('awful')

local function parse(output)
  local volume = tonumber(output:match("(%d?%d?%d)%%"))
  local muted  = output:match("%[(o[nf]*)%]") == 'off'
  return { volume = volume, muted = muted }
end

return function (config)
  local service = {}
  local step = config.step_percent or 10

  function service:state(callback)
    awful.spawn.easy_async_with_shell(
      "amixer sget Master",
      function(stdout)
        callback(parse(stdout))
      end
    )
  end

  function service:toggle(callback)
    awful.spawn.easy_async_with_shell(
      "amixer set Master toggle",
      function(stdout)
        callback(parse(stdout))
      end
    )
  end

  function service:up(callback)
    awful.spawn.easy_async_with_shell(
      "amixer set Master on && amixer set Master " .. step .. "%+",
      function(stdout)
        callback(parse(stdout))
      end
    )
  end

  function service:down(callback)
    awful.spawn.easy_async_with_shell(
      "amixer set Master on && amixer set Master " .. step .. "%-",
      function(stdout)
        callback(parse(stdout))
      end
    )
  end

  return service
end
