{ pkgs, scripts }: ''

local function nix_bin(cmd, args)
  return os.getenv("HOME") .. '/.nix-profile/bin/' .. cmd .. " " .. (args or "")
end

local function awesome_dir(path)
  return os.getenv("HOME") .. "/.config/awesome/src/" .. path
end

local config = {
  theme_path = awesome_dir("themes/default/theme.lua"),
  editor_command = nix_bin('emacsclient', '--create-frame --alternate-editor=emacs'),
  fs_browser = 'nautilus',
  launcher_command = '${pkgs.rofi}/bin/rofi -show run',
  modkey = 'Mod4',
  terminal_command = 'gnome-terminal',
  wifi_manager_command = 'nm-connection-editor',
  toggle_keyboard_command = '${scripts.keyboardToggle}',
  set_keyboard_qwerty = '${scripts.keyboardDvorak}',
  set_keyboard_dvorak = '${scripts.keyboardDvorak}',
  read_layout_command = '${scripts.keyboardShow}',
}

require("rc")(config)

''
