-- Error handling

local awful = require('awful')
local naughty = require("naughty")

local in_error = false

local function open_in_emacs(err)
  local path = "/tmp/awesome-error.stacktrace"
  local file = io.open(path, 'w')
  file:write(tostring(err))
  file:close()

  local sexpr = '(with-current-buffer (find-file "' .. path  .. '") (compilation-minor-mode))'
  awful.spawn {"emacsclient", "--alternate-editor=emacs", "--eval", sexpr}
end

local function notify_error(title, err)
  -- Make sure we don't go into an endless error loop
  if in_error then
    return
  end
  in_error = true

  naughty.notify {
    preset = naughty.config.presets.critical,
    title = title,
    text = "Click to open the backtrace in Emacs.",
    run = function(notification)
      open_in_emacs(err)
      naughty.destroy(notification, naughty.notificationClosedReason.dismissedByUser)
    end,
  }

  in_error = false
end

-- Check if awesome encountered an error during startup.
if awesome.startup_errors then
  notify_error("Error at startup: falling back to system config", awesome.startup_errors)
end

-- Handle runtime errors after startup
awesome.connect_signal("debug::error", function (err)
    notify_error("Error in AwesomeWM configuration", err)
  end
)
