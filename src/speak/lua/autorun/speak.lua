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
end

if CLIENT then
    -- libraries
    include("lib/preferences.lua/preferences.lua")
    include("lib/i18n.lua/i18n.lua")

    -- speak
    include("speak/cl_main.lua")
end
