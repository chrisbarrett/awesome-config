local awful = require('awful')

local function parse(output)
  local volume = tonumber(output:match("(%d?%d?%d)%%"))
  local muted  = output:match("%[(o[nf]*)%]") == 'off'
  return { volume = volume, muted = muted }
end

return function(config)
  local service = {}

  local change_hooks = {}

  function changed(state)
    for _, f in pairs(change_hooks) do
      f(state)
    end
  end

  function service:add_change_hook(func)
    table.insert(change_hooks, func)
  end

  function service.state(callback)
    awful.spawn.easy_async_with_shell(
      "amixer sget Master",
      function(stdout)
        local result = parse(stdout)
        if callback then callback(result) end
      end
    )
  end

  function service.toggle(callback)
    awful.spawn.easy_async_with_shell(
      "amixer set Master toggle",
      function(stdout)
        local result = parse(stdout)
        if callback then callback(result) end
        changed(result)
      end
    )
  end

  function service.up(callback)
    awful.spawn.easy_async_with_shell(
      "amixer set Master on && amixer set Master 10%+",
      function(stdout)
        local result = parse(stdout)
        if callback then callback(result) end
        changed(result)
      end
    )
  end

  function service.down(callback)
    awful.spawn.easy_async_with_shell(
      "amixer set Master on && amixer set Master 10%-",
      function(stdout)
        local result = parse(stdout)
        if callback then callback(result) end
        changed(result)
      end
    )
  end

  function service.openAudioManager()
    awful.spawn(config.audio_manager_program)
  end

  return service
end
