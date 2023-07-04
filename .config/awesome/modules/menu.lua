local gears = require("gears")
local awful = require("awful")

local Menu = { mt = {} }

local function new(params)
    return {
        { "Terminal", params.terminal }, { "Terminal (dark)", params.terminal .. " -r" },
        { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "Development", {
            { "Visual Studio Code", "/home/kraken/HDD/Software/VSCode/code --no-sandbox" },
            { "GIMP", "gimp" },
            { "LibreOffice", "/home/kraken/HDD/Software/LibreOffice.AppImage" },
	    { "Octave", "octave --gui" },
            { "bash", params.terminal .. " bash" }
        } },
        { "Communication", {
            { "Ripcord", "/home/kraken/HDD/Software/Ripcord.AppImage" },
            { "WeeChat", params.terminal .. " -r weechat" },
            { "Telegram", "/home/kraken/HDD/Software/Telegram/Telegram" }
        } },
        { "Sound", {
            { "Jack", "qjackctl" }, { "Carla", "carla" },
            { "MuseScore", "/home/kraken/HDD/Software/MuseScore.AppImage" },
            { "Alsamixer", params.terminal .. " -e alsamixer" },
            { "Audacity", "audacity" },
            { "PureData", "/home/kraken/HDD/Software/pd-0.51-4/bin/pd-gui" }
        } },
        { "System", {
            { "htop", params.terminal .. " -e htop" },
            { "Network Manager", params.terminal .. " -e nmtui" },
            { "9vx", "/home/kraken/HDD/9front/plan9.sh" },
            { "drawterm", "/home/kraken/.local/bin/drawterm -u glenda -a localhost -h localhost" },
            { "Explorer", "wine explorer.exe" },
	    { "Restart AwesomeWM", awesome.restart }
        } },
        { "Gaems", {
            { "Minecraft", "/opt/jre1.8.0_351/bin/java -jar '/home/kraken/HDD/No Gaems/TL.jar'" },
            { "Steam", "steam" },
            { "Hedgewars", "hedgewars" },
            { "Minetest", "minetest" },
	    { "OpenSpades", "/home/kraken/HDD/No\\ Gaems/openspades/openspades.sh" },
            { "Factorio", "/home/kraken/HDD/No\\ Gaems/Factorio/start.sh" }
        } },
        { "Network", {
            { "Firefox", "/home/kraken/HDD/Software/Firefox/firefox" },
            { "Google Chrome", "google-chrome" },
            { "ping", params.terminal .. " -e 'ping 8.8.8.8'" }
        } },
    }
end

function Menu.mt:__call(...)
    return new(...)
end

return setmetatable(Menu, Menu.mt)
