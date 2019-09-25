speak = speak or {}

--[[ Classes ]]
include("sh_globals.lua")
include("sv_tags.lua")
include("sv_resources.lua")

util.AddNetworkString('chat.addtext')

chat = chat or {}
function chat.AddText(...)
  net.Start('chat.addtext')
  net.WriteTable({...})
  net.Broadcast()
end

--[[ Compatability ]]
AddCSLuaFile("compatability/clockwork_compat.lua")
AddCSLuaFile("compatability/darkrp_compat.lua")

--[[ vgui ]]
AddCSLuaFile("vgui/speak_radiobutton.lua")
AddCSLuaFile("vgui/speak_chatbox.lua")
AddCSLuaFile("vgui/speak_settings.lua")

--[[ Classes ]]
AddCSLuaFile("cl_avatarsheet.lua")
AddCSLuaFile("cl_emoticons.lua")
AddCSLuaFile("conf/emoticons.lua")
AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("cl_locale.lua")
AddCSLuaFile("cl_modelsheet.lua")
AddCSLuaFile("cl_tags.lua")
AddCSLuaFile("cl_theme.lua")
AddCSLuaFile("cl_emoji.lua")
