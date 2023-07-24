-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty       = require("naughty")
local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/rio/theme.lua")
naughty.config.defaults.position = "top_middle"

naughty.config.defaults.icon_size = 100

-- This is used later as the default terminal and editor to run.
terminal   = "uxterm"
editor     = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
modkey     = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
}

local wm   = require('modules.windowmanager')
local menu = require('modules.menu')

local function spawndrawterm()
    awful.spawn.with_shell("PASS=`cat $HOME/lib/drawterm` drawterm -u glenda -a localhost -h localhost")
end

mymainmenu = awful.menu {
    items = {
        { "New",     menu { terminal = terminal, spawndrawterm = spawndrawterm } },
        { "Reshape", wm.reshape },
        { "Move",    wm.move },
        { "Delete",  wm.delete },
        { "Hide",    wm.hide },
        { "Exit",    function() awesome.quit() end }
    }
}

-- Menubar configuration
menubar.utils.terminal = terminal

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%H:%M ")

local battery    = require('widgets.battery')
local pulseaudio = require('widgets.pulseaudio')

mybattery = battery {
    callback = function(data)
        return string.format('%d %% (%s) ', data.percent, string.lower(data.status))
    end
}

mypulseaudio = pulseaudio {
    channel_list = {
        { icon = "alsa", channel_type = "sink", label = "Analog Stereo Output",
          name = "alsa_output.pci-0000_00_1f.3.analog-stereo" },
        { icon = "mic", channel_type = "source", label = "Analog Stereo Input",
          name = "alsa_input.pci-0000_00_1f.3.analog-stereo" }
    }
}

local function view_tag(tag)
    if tag then
        tag:view_only()

        for _, c in ipairs(awful.client.focus.history.list) do
            if c:isvisible() then
                client.focus = c
                c:raise()
                break
            end
        end
    end
end

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, view_tag),
    awful.button({ modkey }, 1, function(t)
                              if client.focus then
                                  client.focus:move_to_tag(t)
                              end
                          end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
                              if client.focus then
                                  client.focus:toggle_tag(t)
                              end
                          end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
                             if c == client.focus then
                                 c.minimized = true
                             else
                                 c:emit_signal(
                                     "request::activate",
                                     "tasklist",
                                     {raise = true}
                                 )
                             end
                         end),
    awful.button({ }, 4, function ()
                             awful.client.focus.byidx(1)
                         end),
    awful.button({ }, 5, function ()
                             awful.client.focus.byidx(-1)
                         end)
)

local gap = wibox.widget{
    markup = ' ',
    widget = wibox.widget.textbox
}

local function widgets(s)
    return {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout, gap,
            mybattery, gap,
            mypulseaudio, gap,
            mytextclock, gap,
            s.mylayoutbox,
        },
    }
end

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag.add("9",           { layout = awful.layout.suit.max.fullscreen, screen = s, gap = 0 })
    awful.tag.add("Chats",       { layout = awful.layout.suit.fair,           screen = s })
    awful.tag.add("Web",         { layout = awful.layout.suit.max,            screen = s })
    awful.tag.add("Development", { layout = awful.layout.suit.max,            screen = s })
    awful.tag.add("Sound",       { layout = awful.layout.suit.max,            screen = s })
    awful.tag.add("Gaems",       { layout = awful.layout.suit.floating,       screen = s })
    awful.tag.add("Other",       { layout = awful.layout.suit.floating,       screen = s, selected = true })

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end))
    )

    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style   = { align = "center" }
    }

    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup(widgets(s))
end)

-- Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              { description="show help", group = "awesome" }),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              { description = "view previous", group = "tag" }),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              { description = "view next", group = "tag" }),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              { description = "go back", group = "tag" }),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go forward", group = "client" }),
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal .. " /opt/microsoft/powershell/7/pwsh") end,
              { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey,           }, "p",      function () awful.spawn(terminal .. " -T ping -e 'ping 8.8.8.8'") end,
              { description = "ping", group = "launcher" }),
    awful.key({ modkey,           }, "d",      spawndrawterm,
              { description = "drawterm", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r",      awesome.restart,
              { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit,
              { description = "quit awesome", group = "awesome" }),

    awful.key({ modkey,           }, "l",      function () awful.tag.incmwfact( 0.05)          end,
              { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey,           }, "h",      function () awful.tag.incmwfact(-0.05)          end,
              { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1, nil, true) end,
              { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1, nil, true) end,
              { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1, nil, true)    end,
              { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1, nil, true)    end,
              { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc( 1)                end,
              { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(-1)                end,
              { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      c:emit_signal(
                          "request::activate", "key.unminimize", { raise = true }
                      )
                  end
              end,
              { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              { description = "run prompt", group = "launcher" }),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              { description = "lua execute prompt", group = "awesome" }),
    -- Functional keys
    awful.key({ }, "XF86AudioRaiseVolume", function () mypulseaudio:raise(3) end),
    awful.key({ }, "XF86AudioLowerVolume", function () mypulseaudio:lower(3) end),
    awful.key({ }, "XF86AudioMute", function () mypulseaudio:toggle() end),
    awful.key({ }, "Print", function ()
        os.execute("import -window root png:- | xclip -selection clipboard -t image/png")
    end),
    awful.key({ modkey }, "Print", function ()
        os.execute("cd ~/Pictures/Screenshots && sleep 0.2 && scrot -s")
        naughty.notify {
            preset = naughty.config.presets.normal,
            timeout = 5,
            title = "scrot",
            text = string.format("Created screenshot at %s", os.date("%c"))
        }
    end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              { description = "move to master", group = "client" }),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              { description = "move to screen", group = "client" }),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        { description = "minimize", group = "client" }),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
for i = 0, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, i,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i + 1]
                      view_tag(tag)
                  end,
                  { description = "view tag #"..i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i + 1]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i + 1]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  { description = "move focused client to tag #"..i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i + 1]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = wm.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.centered
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
            "DTA",  -- Firefox addon DownThemAll.
            "copyq",  -- Includes session name in class.
            "pinentry",
            "mpv"
        },
        class = {
            "Arandr",
            "Blueman-manager",
            "Gpick",
            "Kruler",
            "MessageWin",  -- kalarm.
            "Sxiv",
            "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
            "Wpa_gui",
            "veromix",
            "xtightvncviewer",
            "mpv"
        },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
            "Event Tester",  -- xev.
        },
        role = {
            "AlarmWindow",  -- Thunderbird's calendar.
            "ConfigManager",  -- Thunderbird's about:config.
            "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
    }, properties = { floating = true } },

    { rule_any = { type = { "normal", "dialog" } },
      properties = { titlebars_enabled = false } },

    { rule = { class = "firefox", role = "browser" },
      properties = { screen = 1, tag = "Web", floating = false } },

    { rule = { class = "Code" },
      properties = { screen = 1, tag = "Development" } },

    { rule = { instance = "qjackctl" },
      properties = { screen = 1, tag = "Sound", floating = true } },

    { rule_any = { class = { "Carla2", "MuseScore3" } },
      properties = { screen = 1, tag = "Sound" } },

    { rule_any = { class = { "Chatzilla", "Ripcord" } },
      properties = { screen = 1, tag = "Chats" } },

    { rule = { class = "9vx" },
      properties = { screen = 1, tag = "9" } },
}

awful.mouse.snap.edge_enabled = false

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- https://github.com/basaran/awesomewm-backham/blob/master/init.lua
function backham()
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c then
        client.focus = c
        c:raise()
    end
end

client.connect_signal("property::minimized", backham)
client.connect_signal("unmanage", backham)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

screen.connect_signal("arrange", function (s)
    if not s.selected_tag then
        return
    end

    if s.selected_tag.name ~= "9" then
        return
    end

    local fullscreen = s.selected_tag.layout.name == "fullscreen"
    local alone      = #s.tiled_clients == 1
    if fullscreen and alone then
        local c = s.clients[1]
        c.border_width = 0
    else
        for _, c in pairs(s.clients) do
            c.border_width = beautiful.border_width
        end
    end
end)
