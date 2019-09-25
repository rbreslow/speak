if SERVER then
    -- libraries
    include("lib/preferences.lua/preferences.lua")
    AddCSLuaFile("lib/preferences.lua/preferences.lua")

    include("lib/i18n.lua/i18n.lua")

    -- speak
    AddCSLuaFile("speak/cl_main.lua")
    include("speak/sv_main.lua")

    -- conf
    include("conf/tags.lua")

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
    -- libraries
    include("lib/preferences.lua/preferences.lua")
    include("lib/i18n.lua/i18n.lua")

    -- speak
    include("speak/cl_main.lua")
end
