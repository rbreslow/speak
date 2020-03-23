if SERVER then
    AddCSLuaFile "speak/sh_main.lua"
end

include "speak/sh_main.lua"

if SERVER then
    AddCSLuaFile "speak/gen/bundle.lua"
    AddCSLuaFile "speak/gen/emoji_data.lua"

    AddCSLuaFile "speak/lib/avatarsheet.lua"
    AddCSLuaFile "speak/lib/i18n.lua"
    AddCSLuaFile "speak/lib/modelsheet.lua"
    AddCSLuaFile "speak/lib/preferences.lua"

    AddCSLuaFile "speak/vendor/base64.lua"
    AddCSLuaFile "speak/vendor/is.lua"
    AddCSLuaFile "speak/vendor/log.lua"

    AddCSLuaFile "speak/vgui/speak_chatbox.lua"
    AddCSLuaFile "speak/vgui/speak_radiobutton.lua"
    AddCSLuaFile "speak/vgui/speak_settings.lua"

    AddCSLuaFile "speak/cl_emoticons.lua"
    AddCSLuaFile "speak/cl_locale.lua"
    AddCSLuaFile "speak/cl_main.lua"
    AddCSLuaFile "speak/cl_settings.lua"
    AddCSLuaFile "speak/cl_tags.lua"

    include "speak/sv_main.lua"

    if DarkRP then
        AddCSLuaFile("speak/compat/darkrp.lua")
    end
end

if CLIENT then
    include "speak/cl_main.lua"

    if DarkRP then
        include("speak/compat/darkrp.lua")
    end
end
