{ pkgs, scripts, rofi }: ''
require("error_handlers")
local awful = require('awful')

-- Prevent clients from being unreachable after screen count changes.
client.connect_signal(
  "manage",
  function (c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_offscreen(c)
    end
  end
)

local function nix_bin(cmd, args)
  return os.getenv("HOME") .. '/.nix-profile/bin/' .. cmd .. " " .. (args or "")
end

local config = {
  audio_manager_program = '${pkgs.pavucontrol}/bin/pavucontrol',
  xbacklight_path = '${pkgs.xorg.xbacklight}/bin/xbacklight',
  desktop_picture = '${./assets/desktop.png}',
  editor_command = nix_bin('emacsclient', '--create-frame --alternate-editor=emacs'),
  fs_browser = 'nautilus',
  launcher_command = '${rofi}/bin/rofi -show run',
  modkey = 'Mod4',
  terminal_command = 'gnome-terminal',
  wifi_manager_command = 'nm-connection-editor',
  toggle_keyboard_command = '${scripts.keyboardToggle}',
  set_keyboard_qwerty = '${scripts.keyboardDvorak}',
  set_keyboard_dvorak = '${scripts.keyboardDvorak}',
  read_layout_command = '${scripts.keyboardShow}',
}

require("rc")(config)

-- Make sure we reload the xprofile so that keyboard repeat settings are loaded.
awful.spawn.with_shell('~/.xprofile')
''
