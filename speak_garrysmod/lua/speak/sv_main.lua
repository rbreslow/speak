speak = speak or {}

--[[ Classes ]]
include("sh_globals.lua")
include("sv_tags.lua")

util.AddNetworkString('chat.addtext')
util.AddNetworkString('speak.chattextchanged')

chat = chat or {}
function chat.AddText(...)
    net.Start('chat.addtext')
    net.WriteTable({...})
    net.Broadcast()
end

net.Receive("speak.chattextchanged", function(length, player)
    if OVERHEADCHAT_ENABLED then
        local str = net.ReadString()

        if #str > 30 then
            str = string.sub(str, #str - 30, #str)
        end

        player:SetNW2String("chattext", str)
    end
end)

--[[ Compatability ]]
AddCSLuaFile("compatability/clockwork_compat.lua")
AddCSLuaFile("compatability/darkrp_compat.lua")

--[[ Vgui ]]
AddCSLuaFile("vgui/rbreslow_radiobutton.lua")
AddCSLuaFile("vgui/speak_chatbox.lua")
AddCSLuaFile("vgui/speak_settings.lua")

--[[ Classes ]]
AddCSLuaFile("cl_avatarsheet.lua")
AddCSLuaFile("cl_emoticons.lua")
AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("cl_locale.lua")
AddCSLuaFile("cl_modelsheet.lua")
AddCSLuaFile("cl_tags.lua")