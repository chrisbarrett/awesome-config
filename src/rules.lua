-- Rules

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local tyrannical = require('tyrannical')

tyrannical.settings.default_layout = awful.layout.suit.tile
tyrannical.settings.master_width_factor = 0.6
tyrannical.settings.group_children = true

-- Configure main tags rules.

tyrannical.tags = {
  {
    name = "main",
    init = true,
    selected = true,
    fallback = true,
    class = {"Emacs"},
  },
  {
    name = "read",
    init = false,
    exclusive = true,
    volatile = true,
    class = {"chromium", "chromium-browser"},
  },
  {
    name = "comms",
    init = false,
    volatile = true,
    class = {"Slack", "skype"},
  },
  {
    name = "music",
    exclusive = true,
    volatile = true,
    init = false,
    class = {"Spotify", "spotify"},
  },
  {
    name = "video",
    exclusive = true,
    volatile = true,
    init = false,
    class = {"mpv"},
  },
  {
    name = "gaming",
    init = false,
    volatile = true,
    class = {
      "Steam",
      "steam",
      "mono-sgen", -- OpenRA
    },
  },
}

-- Some apps don't apply X properties to clients immediately, so provide a way
-- to apply settings at client display time.

local latebound_client_settings = {
  Spotify = {
    tag = "music",
    settings = { screen = awful.screen.focused(), volatile = true },
  },
}

-- Extra display properties.

tyrannical.properties.intrusive = {
  "nm-connection-editor",
  "pavucontrol",
  "gcr-prompter",
  "pinentry",
  "org.gnome.Nautilus",
  "Gnome-terminal",
}

tyrannical.properties.floating = {
  "pavucontrol",
  "nm-connection-editor",
}

tyrannical.properties.placement = {
  ["gcr-prompter"] = awful.placement.centered,
  ["nm-connection-editor"] = awful.placement.centered,
  ["pavucontrol"] = awful.placement.centered,
}

tyrannical.properties.size_hints_honor = {
  Emacs = false,
  ["Gnome-terminal"] = false,
}

function ensure_tag(name, props)
  local tag = awful.tag.find_by_name(props.screen, name)
  if not tag then
    tag = awful.tag.add(name, props)
  end
  return tag
end

-- Rules to apply to new clients (through the "manage" signal).
function init_rules(config, keybindings)
  return {
    {
      rule = { },
      properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = keybindings.client,
        buttons = gears.table.join(
          awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
          awful.button({ config.modkey }, 1, awful.mouse.client.move),
          awful.button({ config.modkey }, 3, awful.mouse.client.resize)
        ),
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
      },
      callback = function(c)
        awful.client.setslave(c)
        if not c.class and not c.name then
          local client_callback

          client_callback = function(client)
            client:disconnect_signal("property::name", client_callback)

            -- Hook to apply late-bound settings.
            local overrides = latebound_client_settings[client.name]
            if overrides then
              local tag = ensure_tag(overrides.tag, overrides.settings)
              client:tags({tag})
              tag:view_only()
            end
          end

          c:connect_signal("property::name", client_callback)
        end
      end
    },
  }
end

return init_rules
