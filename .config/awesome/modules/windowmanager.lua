local gears     = require("gears")
local awful     = require("awful")
local beautiful = require("beautiful")

local WindowManager = { mt = {} }

local LEFT, CENTER, RIGHT = -1, 0, 1
local BOTTOM, CENTER, TOP = -1, 0, 1

local function get_corner(vertical, horizontal)
    if vertical == BOTTOM then
        if horizontal == LEFT then return "bottom_left"
        elseif horizontal == RIGHT then return "bottom_right"
        else return "bottom"
        end
    elseif vertical == TOP then
        if horizontal == LEFT then return "top_left"
        elseif horizontal == RIGHT then return "top_right"
        else return "top"
        end
    else
        if horizontal == LEFT then return "left"
        elseif horizontal == RIGHT then return "right"
        else return nil
        end
    end
end

-- https://github.com/1jss/awesome-lighter/blob/main/awesome/rc.lua#L446-L454
local function check_border(mx, my, cx, cy, cw, ch)
    local vertical, horizontal = CENTER, CENTER

    if mx < cx + beautiful.border_width then horizontal = LEFT
    elseif mx > cx + cw + beautiful.border_width then horizontal = RIGHT
    end

    if my < cy + beautiful.border_width then vertical = TOP
    elseif my > cy + ch + beautiful.border_width then vertical = BOTTOM
    end

    return get_corner(vertical, horizontal)
end

local function restore_border_color(c)
    c.border_color = beautiful.border_focus
end

awful.mouse.resize.add_leave_callback(restore_border_color, "mouse.move")
awful.mouse.resize.add_leave_callback(restore_border_color, "mouse.resize")

local function onborder(c, callback)
    local mouse    = _G.mouse.coords()
    local geometry = c:geometry()
    local corner   = check_border(
        mouse.x, mouse.y,
        geometry.x, geometry.y,
        geometry.width, geometry.height
    )

    if corner then
        callback(c, corner)
    end
end

local function move(c)
    c.border_color = beautiful.border_active
    awful.mouse.client.move(c)
end

local function resize(c, corner)
    c.border_color = beautiful.border_active
    awful.mouse.client.resize(c, corner)
end

local lmbstate = "focus"
local lmbcallback = {
    delete = function (c)
        c:kill()
    end,
    move = move,
    reshape = resize,
    hide = function (c)
        c.minimized = true
        c:raise()
    end,
    focus = function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        onborder(c, resize)
    end
}

root.buttons(gears.table.join(
    awful.button({ }, 1, function ()
        mymainmenu:hide()
        lmbstate = "focus"
    end),
    awful.button({ }, 3, function ()
        mymainmenu:toggle()
        lmbstate = "focus"
    end)
))

WindowManager.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        mymainmenu:hide()
        lmbcallback[lmbstate](c)
        lmbstate = "focus"
    end),

    awful.button({ }, 3, function (c)
        mymainmenu:hide()
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        onborder(c, move)
        lmbstate = "focus"
    end),

    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        move(c)
    end),

    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        resize(c)
    end)
)

function WindowManager.reshape()
    lmbstate = "reshape"
end

function WindowManager.move()
    lmbstate = "move"
end

function WindowManager.delete()
    lmbstate = "delete"
end

function WindowManager.hide()
    lmbstate = "hide"
end

return setmetatable(WindowManager, WindowManager.mt)