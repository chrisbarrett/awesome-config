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
