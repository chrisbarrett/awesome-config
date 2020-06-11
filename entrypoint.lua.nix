{ pkgs, scripts }: ''
require('error_handlers')
local awful = require('awful')

local config = {
  desktop_picture = '${./assets/desktop.png}',
  toggle_keyboard_command = '${scripts.keyboardToggle}',
  set_keyboard_qwerty = '${scripts.keyboardDvorak}',
  set_keyboard_dvorak = '${scripts.keyboardDvorak}',
  read_layout_command = '${scripts.keyboardShow}',
}

require('rc')(config)

-- Make sure we reload the xprofile so that keyboard repeat settings are loaded.
awful.spawn.with_shell('~/.xprofile')
''
