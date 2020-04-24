local awful = require('awful')
local naughty = require('naughty')

local layouts = {
  ['us(dvp)'] = 'dvorak',
  ['us'] = 'qwerty',
}

local function parse(stdout)
  local trimmed = stdout.gsub(stdout, '[ \t\n\r]', '')
  local layout = layouts[trimmed] or trimmed
  return { layout = layout }
end


local notification

function show_notification(state)
    if notification then
      naughty.destroy(notification)
      notification = nil
    end

    notification = naughty.notify {
      title = 'Keyboard',
      text = "Keyboard layout changed to " .. state.layout .. "."
    }
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

  service:add_change_hook(show_notification)

  function service.state(callback)
    awful.spawn.easy_async_with_shell(
      config.read_layout_command,
      function(stdout)
        local result = parse(stdout)
        if callback then callback(result) end
      end
    )
  end

  function service.set_dvorak(callback)
    awful.spawn.easy_async_with_shell(
      config.set_keyboard_dvorak,
      function()
        local state = { layout = 'dvorak'}
        if callback then callback(state) end
        service.changed(state)
      end
    )
  end

  function service.set_qwerty(callback)
    awful.spawn.easy_async_with_shell(
      config.set_keyboard_dvorak,
      function()
        local state = { layout = 'qwerty'}
        if callback then callback(state) end
        service.changed(state)
      end
    )
  end

  function service.toggle_layout(callback)
    awful.spawn.easy_async_with_shell(
      config.toggle_keyboard_command,
      function()
        service.state(function (state)
          if callback then callback(state) end
          service.changed(state)
        end)
      end
    )
  end

  return service
end
