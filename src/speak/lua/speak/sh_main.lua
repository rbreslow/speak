CreateConVar("speak_version", include "speak/static/version.lua", bit.bor(FCVAR_SPONLY, FCVAR_REPLICATED, FCVAR_NOTIFY), "")

IS = include "vendor/is.lua"

speak = speak or {}
include "config/sh_settings.lua"

speak.logger = include "vendor/log.lua"
speak.logger.name = "speak"
speak.logger.level = speak.settings.LOG_LEVEL

--- Creates an avatar to be used in chat.AddText()
-- @param client The player object to use
function ChatAvatar(client)
  local x, y = speak.avatarSheet:PlayerToPos(client)
  
  return {
    steamId = client:SteamID64() or "",
    sheetX = x,
    sheetY = y
  }
end

--- Creates an image to be used in chat.AddText()
-- @param url The url to the image
function ChatImage(url)
  -- If we're getting it locally
  if file.Exists('materials/' .. url, 'GAME') then
    url = 'data:image/png;base64,' .. util.Base64Encode(file.Read('materials/' .. url, 'GAME'))
  end

  return {
    url = url
  }
end

--- Creates an object to increase/decrease the font size of the next element
-- @param change The value to change font size by
function ChatFontMultiplier(multiplier)
  return {
    value = multiplier
  }
end
