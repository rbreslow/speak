if SERVER then
    local _R = debug.getregistry()
    if (not _R.Entity.SetNW2String) then _R.Entity.SetNW2String = _R.Entity.SetNWString end

    --[[ Libraries ]]
    include("lib/preferences.lua/preferences.lua")
    AddCSLuaFile("lib/preferences.lua/preferences.lua")

    include("lib/i18n.lua/i18n.lua")

    --[[ Speak ]]
    AddCSLuaFile("speak/cl_main.lua")
    include("speak/sv_main.lua")

    --[[ Conf ]]
    AddCSLuaFile("conf/emoticons.lua")
    include("conf/policy.lua")
    include("conf/tags.lua")
    include("conf/overheadchat.lua")
    AddCSLuaFile("conf/theme.lua")

    --[[ Resources ]]
    resource.AddFile("sound/speak/boing.mp3")
    resource.AddFile("sound/speak/ding.mp3")
    resource.AddFile("sound/speak/drop.mp3")
    resource.AddFile("sound/speak/here_you_go.mp3")
    resource.AddFile("sound/speak/hi.mp3")
    resource.AddFile("sound/speak/knock_brush.mp3")
    resource.AddFile("sound/speak/plink.mp3")
    resource.AddFile("sound/speak/ta_da.mp3")
    resource.AddFile("sound/speak/woah.mp3")
    resource.AddFile("sound/speak/yoink.mp3")
    resource.AddFile("sound/speak/wow.mp3")

    resource.AddFile("resource/fonts/CoolveticaBk-Italic.ttf")
    resource.AddFile("resource/fonts/CoolveticaBk-Regular.ttf")
    resource.AddFile("resource/fonts/CoolveticaEl-Italic.ttf")
    resource.AddFile("resource/fonts/CoolveticaEl-Regular.ttf")
    resource.AddFile("resource/fonts/CoolveticaHv-Italic.ttf")
    resource.AddFile("resource/fonts/CoolveticaHv-Regular.ttf")
    resource.AddFile("resource/fonts/CoolveticaLt-Italic.ttf")
    resource.AddFile("resource/fonts/CoolveticaLt-Regular.ttf")
    resource.AddFile("resource/fonts/CoolveticaRg-Bold.ttf")
    resource.AddFile("resource/fonts/CoolveticaRg-BoldItalic.ttf")
    resource.AddFile("resource/fonts/CoolveticaRg-Italic.ttf")
    resource.AddFile("resource/fonts/CoolveticaRg-Regular.ttf")
    resource.AddFile("resource/fonts/CoolveticaUl-Italic.ttf")
    resource.AddFile("resource/fonts/CoolveticaUl-Regular.ttf")
end

if CLIENT then
    local _R = debug.getregistry()
    if (not _R.Entity.GetNW2String) then _R.Entity.GetNW2String = _R.Entity.GetNWString end

    --[[ Libraries ]]
    include("lib/preferences.lua/preferences.lua")

    include("lib/i18n.lua/i18n.lua")

    --[[ Speak ]]
    include("conf/theme.lua")
    include("speak/cl_main.lua")

    --[[ Conf ]]
    include("conf/emoticons.lua")
end
