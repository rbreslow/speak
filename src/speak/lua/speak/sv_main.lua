speak = speak or {}

speak.tags = include "sv_tags.lua"
include "config/sv_tags.lua"
speak.tags:UpdateClients()

include "sv_resource.lua"

chat = chat or {}

util.AddNetworkString("speak.chataddtext")

function chat.AddText(...)
  net.Start("speak.chataddtext")
  net.WriteTable({...})
  net.Broadcast()
end
