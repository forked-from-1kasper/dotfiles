-- https://github.com/vladimir-g/fainty/blob/master/widgets/battery.lua

local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function dummy(data)
    return '(callback) '
end

local Battery = { mt = {} }
Battery.path = '/sys/class/power_supply/'

function Battery:new(bat)
    local instance = { name = bat, path = Battery.path .. bat .. '/' }
    setmetatable(instance, { __index = Battery })
    return instance
end

function Battery:read(val)
    local path = self.path .. val
    local fd   = io.open(path, 'r')

    if not fd then return nil end
    data = fd:read('*all')
    fd:close()

    return trim(data)
end

function Battery:getint(val)
    return tonumber(self:read(val))
end

function Battery:is_present()
    local present = self:read('present')
    if present == '1' then
        return true
    else
        return false
    end
end

function Battery:status()
    local data = { status = self:read('status'),
                   percent = nil, current = nil,
                   full = nil, rate = nil,
                   present = self:is_present() }

    data.percent = self:getint('capacity')
    if self:read('energy_now') then
        data.current = self:getint('energy_now')
        data.full    = self:getint('energy_full')
        data.rate    = self:getint('power_now')
    elseif self:read('charge_now') then
        data.current = self:getint('charge_now')
        data.full    = self:getint('charge_full')
        data.rate    = self:getint('current_now')
    else
        return data
    end

    if not data.percent then
        data.percent = math.min(math.floor(data.current / data.full * 100), 100)
    end
    return data
end

local BatteryWidget = { mt = {} }

function BatteryWidget:refresh()
    local bat = self.battery
    if bat == nil then
        self:set_markup('(N/A) ')
        return
    end

    local data = bat:status()
    self:set_markup(self.callback(data))
end

function BatteryWidget.mt:__call(args)
    local obj = wibox.widget.textbox()

    obj.battery  = Battery:new(args and args.battery or 'BAT0')
    obj.timeout  = args and args.timeout or 10
    obj.callback = args.callback or dummy

    for k, v in pairs(BatteryWidget) do
        obj[k] = v
    end

    obj:refresh()

    timer = gears.timer{ timeout = obj.timeout }
    timer:connect_signal("timeout", function() obj:refresh() end)
    timer:start()

    return obj
end

return setmetatable(BatteryWidget, BatteryWidget.mt)