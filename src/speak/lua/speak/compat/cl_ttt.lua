-- define these here so we don't get translations on every chat message
local lastWords
local traitor
local detective

-- luacheck: globals LANG
local function TTTLanguageChanged()
  lastWords = string.format("(%s) ", LANG.GetTranslation("last_words"):upper())
  traitor = string.format("(%s) ", LANG.GetTranslation("traitor"):upper())
  detective = string.format("(%s) ", LANG.GetTranslation("detective"):upper())
  
  speak.logger.trace "refreshed terrortown compatibility strings"
end

hook.Add("InitPostEntity", "speak.compat.ttt", TTTLanguageChanged)
hook.Add("TTTLanguageChanged", "speak.compat.ttt", TTTLanguageChanged)

local pairs = pairs
local player = player
local function findPlayer(str)
  for _,v in pairs(player.GetAll()) do  
    if str == v:Nick() then
      return v
    end
  end

  return str
end

local type = type
hook.Add("SpeakPreParseChatText", "speak.compat.ttt", function(message) 
  if type(message[2]) == "string" and type(message[4]) == "string" then
    local roleChat = message[2] == lastWords or
                    message[2] == traitor or
                    message[2] == detective

    if roleChat then
      -- https://github.com/Facepunch/garrysmod/blob/394ae745df8f8f353ea33c8780f012fc000f4f56/garrysmod/gamemodes/terrortown/gamemode/cl_voice.lua#L9
      message[4] = findPlayer(message[4])
    else
      -- https://github.com/Facepunch/garrysmod/blob/394ae745df8f8f353ea33c8780f012fc000f4f56/garrysmod/gamemodes/terrortown/gamemode/cl_voice.lua#L68
      message[2] = findPlayer(message[2])
    end
  end
end)

speak.logger.trace "terrortown compatibility"
