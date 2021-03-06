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
    class = {
      "Emacs",
      "gcr-prompter",
    },
  },
  {
    name = "read",
    init = false,
    exclusive = true,
    volatile = true,
    class = {
      "chromium",
      "chromium-browser",
      "gcr-prompter",
    },
  },
  {
    name = "comms",
    init = false,
    volatile = true,
    class = {"Slack", "skype", "discord"},
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
    class = {"mpv", "vlc"},
  },
  {
    name = "gaming",
    init = false,
    volatile = true,
    class = {
      "Steam",
      "steam",
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

return function (config, keybindings)
  local rules = {
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

  function rules.install()
    client.connect_signal("mouse::enter", function(c)
      c:emit_signal("request::activate", "mouse_enter", {raise = false})
    end)

    awful.layout.layouts = {
      awful.layout.suit.tile,
      awful.layout.suit.max,
    }

    -- Prevent clients from being unreachable after screen count changes.
    client.connect_signal(
      "manage",
      function (c)
        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
          awful.placement.no_offscreen(c)
        end
      end
    )

    awful.rules.rules = rules
  end

  return rules
end
