if SERVER then
    AddCSLuaFile "speak/sh_main.lua"
end

include "speak/sh_main.lua"

if SERVER then
    AddCSLuaFile "speak/config/cl_emoticons.lua"
    AddCSLuaFile "speak/config/sh_settings.lua"

    AddCSLuaFile "speak/gen/bundle.lua"
    AddCSLuaFile "speak/gen/emoji_data.lua"
    AddCSLuaFile "speak/gen/version.lua"

    AddCSLuaFile "speak/lib/avatarsheet.lua"
    AddCSLuaFile "speak/lib/i18n.lua"
    AddCSLuaFile "speak/lib/modelsheet.lua"
    AddCSLuaFile "speak/lib/preferences.lua"

    AddCSLuaFile "speak/vendor/base64.lua"
    AddCSLuaFile "speak/vendor/is.lua"
    AddCSLuaFile "speak/vendor/log.lua"

    AddCSLuaFile "speak/vgui/speak_chatbox.lua"
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

    AddCSLuaFile "speak/cl_emoticons.lua"
    AddCSLuaFile "speak/cl_locale.lua"
    AddCSLuaFile "speak/cl_main.lua"
    AddCSLuaFile "speak/cl_tags.lua"
    AddCSLuaFile "speak/cl_util.lua"

    include "speak/sv_main.lua"

    if engine.ActiveGamemode() == "darkrp" then
        AddCSLuaFile "speak/compat/cl_darkrp.lua"
    end

    if engine.ActiveGamemode() == "terrortown" then
        AddCSLuaFile "speak/compat/cl_ttt.lua"
    end
end

if CLIENT then
    include "speak/cl_main.lua"

    if engine.ActiveGamemode() == "darkrp" then
        include "speak/compat/cl_darkrp.lua"
    end

    if engine.ActiveGamemode() == "terrortown" then
        include "speak/compat/cl_ttt.lua"
    end
end
