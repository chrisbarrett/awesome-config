local awful = require("awful")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local utils = require('utils')

local function orgfile(name)
  return os.getenv("HOME") .. "/Dropbox/org/" .. name .. ".org"
end

return function (config)
  config.org_files = {
    orgfile("personal"),
    orgfile("personal_recurring"),
  }

  local props = require('props')(config, hooks)
  props.services = {
    brightness = require('services.brightness')(config),
    keyboard = require('services.keyboard')(config),
    volume = require('services.volume')(config),
  }

  local theme = require('theme')(config)
  theme.install()

  local keybindings = require('keybindings')(config, props)
  root.keys(keybindings.global)

  awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
  }

  awful.rules.rules = require('rules')(config, keybindings)

  local menubar = require("widgets.menubar")(config, props, {
    battery = require("widgets.battery")(config, props),
    brightness = require("widgets.brightness")(props.services.brightness),
    keyboard = require("widgets.keyboard")(props.services.keyboard),
    org_todos = require('widgets.org_todos')(config, props),
    volume = require('widgets.volume')(props.services.volume),
    wifi = require('widgets.wifi')(config, props),
  })

  menubar.install()
end
