local awful = require('awful')

return function(config, hooks)
  local volume = require('services.volume')(config)

  local props = {}

  function props.currentVolume(callback)
    volume:state(callback)
  end

  function props.volumeUp()
    volume:up(function ()
      for _, f in pairs(hooks.volume_changed) do
        f(1)
      end
    end)
  end

  function props.volumeDown()
    volume:down(function ()
      for _, f in pairs(hooks.volume_changed) do
        f(-1)
      end
    end)
  end

  function props.toggleMute()
    volume:toggle(function ()
      for _, f in pairs(hooks.volume_changed) do
        f(0)
      end
    end)
  end

  function props.currentBrightness(callback)
    awful.spawn.easy_async_with_shell(
      config.xbacklight_path .. " -get",
      function(stdout)
        local trimmed = stdout.gsub(stdout, '[ \t\n\r]', '')
        local value = math.floor(0.5 + tonumber(trimmed))
        callback(value)
    end)
  end


  function props.brightnessUp()
    awful.spawn.easy_async_with_shell(
      config.xbacklight_path .. " -inc 10%",
      function()
        for _, f in pairs(hooks.brightness_changed) do
          f(1)
        end
      end
    )
  end

  function props.brightnessDown()
    awful.spawn.easy_async_with_shell(
      config.xbacklight_path .. " -dec 10%",
      function()
        for _, f in pairs(hooks.brightness_changed) do
          f(-1)
        end
      end
    )
  end

  function props.openAudioManager()
    awful.spawn(config.audio_manager_program)
  end

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
