local awful = require('awful')

return function(config, hooks)
  local props = {}
  function props.openEditor()
    awful.spawn(config.editor_command)
  end

  function props.openFSBrowser()
    awful.spawn(config.fs_browser)
  end

  function props.openTerminal()
    awful.spawn(config.terminal_command)
  end

  function props.openLauncher ()
    awful.spawn(config.launcher_command)
  end

  function props.openWifiManager()
    awful.spawn(config.wifi_manager_command)
  end

  function props.setKeyboardLayoutDvorak()
    awful.spawn.easy_async_with_shell(
      config.set_keyboard_dvorak,
      function()
        for _, f in pairs(hooks.keyboard_changed) do
          f('us(dvp)')
        end
      end
    )
  end

  function props.setKeyboardLayoutQwerty()
    awful.spawn.easy_async_with_shell(
      config.set_keyboard_qwerty,
      function()
        for _, f in pairs(hooks.keyboard_changed) do
          f('us')
        end
      end
    )
  end

  function props.toggleKeyboardLayout()
    awful.spawn.easy_async_with_shell(
      config.toggle_keyboard_command,
      function()
        for _, f in pairs(hooks.keyboard_changed) do
          f()
        end
      end
    )
  end

  function props.prevSong ()
    awful.spawn("sp prev")
  end

  function props.playPauseSong ()
    awful.spawn("sp play")
  end

  function props.nextSong ()
    awful.spawn("sp next")
  end

  return props
end
