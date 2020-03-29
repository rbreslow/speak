-- [[ Policy ]]
local Policy = include "lib/preferences.lua"
local policy = Policy("speak")

-- policy:Enforce("avatars_enabled", true)

policy:UpdateClients()
