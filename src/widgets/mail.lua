local vicious = require('vicious')
local wibox = require('wibox')

local function render(widget, args)
  local new = args[1]
  local unread = args[2]
  local total = new + unread

  if total > 0 then
    return " " .. total .. "  "
  else
    return ""
  end
end

return function (config, props)
  local maildir = os.getenv("HOME") .. "/Maildir/walrus/Inbox"
  local widget = wibox.widget.textbox()

  local is_success = pcall(vicious.register, vicious.widgets.mdir, render, 7, { maildir })

  if is_success then
    return widget
  end
end
