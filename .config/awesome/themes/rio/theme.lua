local theme_assets = require("beautiful.theme_assets")
local xresources   = require("beautiful.xresources")
local dpi          = xresources.apply_dpi

local gfs         = require("gears.filesystem")
local themes_path = gfs.get_configuration_dir().."themes/"

local theme = {}

theme.font          = "DejaVu Sans 8"
theme.background    = "#777777"

theme.bg_normal     = "#00000000"
theme.bg_focus      = "#00000000"
theme.bg_urgent     = "#00000000"
theme.bg_minimize   = "#00000000"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#888888"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#aaaaaa"
theme.fg_minimize   = "#bbbbbb"

theme.useless_gap   = dpi(5)
theme.border_width  = dpi(5)

theme.border_marked = "#eeeeee"

theme.border_normal = "#dddddd"
theme.border_focus  = "#cccccc"
theme.border_active = "#ff0000"

--theme.border_normal = "#9EEEEE"
--theme.border_focus  = "#55AAAA"
--theme.border_active = "#ff0000"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

theme.hotkeys_bg           = "#ffffff"
theme.hotkeys_fg           = "#000000"
theme.hotkeys_border_color = "#cccccc"

theme.tasklist_disable_icon = true
theme.tasklist_plain_task_name = true

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

theme.notification_bg = "#ffffff"
theme.notification_fg = "#000000"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]

theme.menu_submenu_icon = themes_path.."submenu.png"
theme.menu_height       = dpi(15)
theme.menu_width        = dpi(150)
theme.menu_border_width = dpi(1)
theme.menu_border_color = "#dddddd"
theme.menu_fg_normal    = "#000000"
theme.menu_fg_focus     = "#000000"
theme.menu_bg_normal    = "#ffffff"
theme.menu_bg_focus     = "#dddddd"

theme.wallpaper  = themes_path.."background.png"
theme.icon_theme = nil

return theme
