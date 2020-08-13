if SERVER then
    AddCSLuaFile "speak/sh_main.lua"
end

include "speak/sh_main.lua"

if SERVER then
    AddCSLuaFile "speak/config/cl_emoji.lua"
    AddCSLuaFile "speak/config/sh_settings.lua"

    AddCSLuaFile "speak/gen/version.lua"

    AddCSLuaFile "speak/lib/avatarsheet.lua"
    AddCSLuaFile "speak/lib/i18n.lua"
    AddCSLuaFile "speak/lib/modelsheet.lua"
    AddCSLuaFile "speak/lib/preferences.lua"

    AddCSLuaFile "speak/static/bundle.lua"
    AddCSLuaFile "speak/vendor/is.lua"
    AddCSLuaFile "speak/vendor/log.lua"

    AddCSLuaFile "speak/vgui/chatbox.lua"
    AddCSLuaFile "speak/vgui/checkbox.lua"
    AddCSLuaFile "speak/vgui/grid.lua"
    AddCSLuaFile "speak/vgui/menu.lua"
    AddCSLuaFile "speak/vgui/messages.lua"
    AddCSLuaFile "speak/vgui/notifications.lua"
    AddCSLuaFile "speak/vgui/radiobutton.lua"
    AddCSLuaFile "speak/vgui/radiorow.lua"
    AddCSLuaFile "speak/vgui/roundedavatarimage.lua"
    AddCSLuaFile "speak/vgui/roundeddmodelpanel.lua"
    AddCSLuaFile "speak/vgui/themes.lua"

    AddCSLuaFile "speak/cl_emoji.lua"
    AddCSLuaFile "speak/cl_locale.lua"
    AddCSLuaFile "speak/cl_main.lua"
    AddCSLuaFile "speak/cl_tags.lua"
    AddCSLuaFile "speak/cl_util.lua"

    include "speak/sv_main.lua"

    if engine.ActiveGamemode() == "terrortown" then
        AddCSLuaFile "speak/compat/cl_ttt.lua"
    end
end

if CLIENT then
    include "speak/cl_main.lua"

    if engine.ActiveGamemode() == "terrortown" then
        include "speak/compat/cl_ttt.lua"
    end
end

local function LoadCompatibility()
    if util.NetworkStringToID("DarkRP_Chat") ~= 0 then
        if SERVER then
            AddCSLuaFile "speak/compat/cl_darkrp.lua"
        elseif CLIENT then
            include "speak/compat/cl_darkrp.lua"
        end
    end
end
hook.Add("Initialize", "speak_LoadCompatibility", LoadCompatibility)
