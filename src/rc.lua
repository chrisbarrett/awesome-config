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

  local props = require('props')(config, {
    brightness = require('services.brightness')(config),
    keyboard = require('services.keyboard')(config),
    volume = require('services.volume')(config),
  })

  local theme = require('theme')(config)
  theme.install()

  local keybindings = require('keybindings')(config, props)
  keybindings.install()

  local rules = require('rules')(config, keybindings)
  rules.install()

  local menubar = require("widgets.menubar")(config, props)
  menubar.install()
end
