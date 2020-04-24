local awful = require('awful')

local function parse(stdout)
  local trimmed = stdout.gsub(stdout, '[ \t\n\r]', '')
  local brightness = math.floor(0.5 + tonumber(trimmed))
  return { brightness = brightness }
end

return function (config)
  local service = {}
  local change_hooks = {}

  function service.changed(state)
    for _, f in pairs(change_hooks) do
      f(state)
    end
  end

  function service:add_change_hook(func)
    table.insert(change_hooks, func)
  end

  function service.state(callback)
    awful.spawn.easy_async_with_shell(
      config.xbacklight_path .. ' -get',
      function(stdout)
        local result = parse(stdout)
        if callback then callback(result) end
    end)
  end

  function service.up(callback)
    awful.spawn.easy_async_with_shell(
      config.xbacklight_path .. ' -inc 10%',
      function()
        service.state(function(result)
            if callback then callback(result) end
            service.changed(result)
        end)
      end
    )
  end

  function service.down(callback)
    awful.spawn.easy_async_with_shell(
      config.xbacklight_path .. ' -dec 10%',
      function()
        service.state(function(result)
            if callback then callback(result) end
            service.changed(result)
        end)
      end
    )
  end

  return service
end
