speak = speak or {}

IS = include "vendor/is.lua"

speak.logger = include "vendor/log.lua"
speak.tags = include "sv_tags.lua"
speak.settings = include "sv_settings.lua"

speak.tags:UpdateClients()

include "sv_resource.lua"

chat = chat or {}

util.AddNetworkString("speak.chataddtext")

function chat.AddText(...)
  net.Start("speak.chataddtext")
  net.WriteTable({...})
  net.Broadcast()
end
