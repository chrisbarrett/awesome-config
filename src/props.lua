local awful = require('awful')
local naughty = require('naughty')

return function(config, services)
  local props = { services = services }

  function props.openAudioManager()
    awful.spawn(os.getenv("AWESOME_AUDIO_MANAGER_COMMAND"))
  end

  function props.toggle_theme()
    awful.spawn(os.getenv("HOME") .. "/.local/bin/theme-toggle")
  end

  function props.openEditor()
    awful.spawn(config.editor_command)
  end

  function props.hasBattery()
    return os.execute("upower -e | grep -i battery")
  end

  function props.openBrowser()
    awful.spawn(os.getenv("AWESOME_BROWSER_COMMAND"))
  end

  function props.openFSBrowser()
    awful.spawn(os.getenv("AWESOME_FILE_MANAGER_COMMAND"))
  end

  function props.openTerminal()
    awful.spawn(os.getenv("AWESOME_TERMINAL_COMMAND"))
  end

  function props.openLauncher ()
    awful.spawn(os.getenv("AWESOME_LAUNCHER_COMMAND"))
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
