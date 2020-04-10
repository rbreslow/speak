local type = type
local table = table
local ipairs = ipairs
local player = player

local function extractPlayer(str)
    for _,v in ipairs(player.GetAll()) do
        local startPos, endPos = str:find(v:Nick())

        if startPos ~= nil then
            local prefix = str:sub(1, startPos - 1)
            local suffix = str:sub(endPos + 1) 

            return prefix, v, suffix
        end
    end

    return nil, nil, nil
end

hook.Add("SpeakPreParseChatText", "speak.compat.darkrp", function(message) 
  local len = #message

  if len < 2 then
    return
  end

  for i = 1, len do
    if type(message[i]) == "string" then
      local prefix, ply, suffix = extractPlayer(message[i])

      if prefix ~= nil and ply ~= nil and suffix ~= nil then
        table.insert(message, i + 1, suffix)
        message[i] = ply
        table.insert(message, i, prefix)
      end
    end
  end
end)

local prefs = speak.prefs

prefs:DefineBoolean("darkrp_tags", false, function(_) end)

local needles = {"(ooc)", "[to admins]"}
for i = 1, #needles do
  needles[i] = needles[i]:PatternSafe()
end
hook.Add("SpeakShouldShowTag", "speak.compat.darkrp", function(message)
  if prefs:Get("darkrp_tags") then
    return
  end

  local data = message[2]

  if type(data) == "string" then
    local haystack = message[2]:lower()
    local found = false

    for i = 1, #needles do
      if haystack:find("^" .. needles[i]) then
        found = true
      end
    end

    if not found then
      return false
    end
  end
end)

speak.i18n:Set("RP_TAGS", "Display tags outside of (OOC) chat", "en")

hook.Add("SpeakSettingsTagStyle", "speak.compat.darkrp", function(_, tagStyle)
  local check = speak.vgui.CheckBoxLabel(speak.i18n:Translate("RP_TAGS"), tagStyle)
  check:SetValue(prefs:Get("darkrp_tags"))
  check.OnChange = function(self, value)
      prefs:SetBoolean("darkrp_tags", value)
  end
  check:SetEnabled(not prefs:IsEnforced("darkrp_tags"))
  check:DockMargin(8, 0, 8, 8)
end)

speak.logger.trace "darkrp compatibility"
