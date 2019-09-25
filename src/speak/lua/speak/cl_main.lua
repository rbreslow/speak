speak = speak or {}

-- [[ classes ]]
include("cl_avatarsheet.lua")
include("cl_emoticons.lua")
include("sh_globals.lua")
include("cl_locale.lua")
include("cl_modelsheet.lua")
include("cl_tags.lua")
include("cl_theme.lua")
include("cl_emoji.lua")

-- [[ static references ]]
speak.prefs = Preferences("speak")

-- [[ general preferences ]]
speak.prefs:DefineBoolean("tag_position", true, function(_) end)

-- [[ emoji preferences ]]
speak.prefs:DefineNumber("emoji_pack", 1, function(value)
  value = math.Clamp(value, 1, 4)
  
  local pack = "apple"
  
  if value == 2 then
    pack = "google"
  elseif value == 3 then
    pack = "twitter"
  elseif value == 4 then
    pack = "facebook"
  end

  speak.view.html:RunJavascript(string.format(
    "speakJS.ChatboxState.setEmojiSet(\"%s\");", pack
  ))
end)

speak.prefs:DefineBoolean("emoji_enabled", true, function(value) 
  speak.view:SetBooleanProperty("emojiEnabled", value)
end)

-- [[ timestamp preferences ]]
speak.prefs:DefineBoolean("timestamps_enabled", true, function(_) end)
speak.prefs:DefineBoolean("timestamps_type", true, function(_) end)
speak.prefs:DefineTable("timestamps_color", Color(114, 188, 212), function(_) end)

-- [[ chat positioning references ]]
speak.prefs:DefineNumber("chatbox_w", 614, function(value)
  speak.view:SetSize(value, speak.prefs:Get("chatbox_h"))
end)

speak.prefs:DefineNumber("chatbox_h", 376, function(value)
  speak.view:SetSize(speak.prefs:Get("chatbox_w"), value)
end)

speak.prefs:DefineNumber("chatbox_x", 30, function(value)
  speak.view:SetPos(value, speak.prefs:Get("chatbox_y"))
end)

speak.prefs:DefineNumber("chatbox_y", ScrH() - (speak.prefs:Get("chatbox_h") * 1.5), function(value)
  speak.view:SetPos(speak.prefs:Get("chatbox_x"), value)
end)

-- [[ avatar preferences ]]
function speak.UpdateAvatars()
  speak.avatarSheet:Update(function(data)
    speak.view:SetStringProperty("avatarSheet", data)
  end)
end

speak.prefs:DefineBoolean("avatars_enabled", false, function(value)
  speak.view.html:RunJavascript(string.format(
    "speakJS.default.setAvatarEnabled(%s);",
    value and "true" or "false"
  ))
end)

speak.playerModelCache = {}
speak.prefs:DefineBoolean("avatars_type", false, function(value)
  speak.avatarSheet = value and ModelSheet() or AvatarSheet()

  if value then
    hook.Add("Think", "speak.Think", function()
      for _,player in pairs(player.GetAll()) do
        local id = player:UserID()
        local model = player:GetModel()

        if speak.playerModelCache[id] ~= model then
          speak.UpdateAvatars()
        end

        speak.playerModelCache[id] = model
      end
    end)
  else
    hook.Remove("Think", "speak.Think")
  end

  -- AvatarSheet is initialized before InitPostEntity
  if(#player.GetAll() > 0) then
    speak.UpdateAvatars()
  end
end)

-- [[ font preferences ]]
speak.prefs:DefineString("font_name", "Inter", function(value)
  speak.view.html:RunJavascript(string.format(
    "speakJS.ChatboxState.setFontName(\"%s\");",
    value
  ))
end)

speak.prefs:DefineNumber("font_size", 12, function(value)
  speak.view.html:RunJavascript(string.format(
    "speakJS.ChatboxState.setFontSize(%s);",
    value
  ))
end)

speak.prefs:DefineNumber("font_weight", 500, function(value)
  speak.view.html:RunJavascript(string.format(
    "speakJS.ChatboxState.setFontWeight(%s);",
    value
  ))
end)

speak.prefs:DefineBoolean("font_border_type", true, function(value)
  speak.view.html:RunJavascript(string.format(
    "speakJS.default.setFontBorderType(%s);",
    value and "true" or "false"
  ))
end)

speak.prefs:DefineNumber("font_border_blur", .5, function(value)
  speak.view.html:RunJavascript(string.format(
    "speakJS.default.setFontBorderBlur(%s);",
    value
  ))
end)

speak.prefs:DefineNumber("font_border_opacity", .75, function(value)
  speak.view.html:RunJavascript(string.format(
    "speakJS.default.setFontBorderOpacity(%s);",
    value
  ))
end)

speak.prefs:DefineNumber("notification_sound", 1, function(_) end)
speak.prefs:DefineNumber("notification_duration", 10, function(_) end)
speak.prefs:DefineBoolean("notification_enabled", true, function(_) end)

speak.notificationSounds = {
  "ding",
  "ta_da",
  "here_you_go",
  "knock_brush",
  "boing",
  "plink",
  "hi",
  "woah",
  "drop",
  "wow",
  "yoink"
}

-- [[ chat library overrides ]]
function chat.AddText(...)
  local message = speak.ParseChatText(...)
  
  speak.view:AppendLine(message)
  
  local consoleMessage = {}
  
  if speak.prefs:Get("timestamps_enabled") then
    consoleMessage = {
      speak.prefs:Get("timestamps_color"),
      "(",
      os.date(speak.prefs:Get("timestamps_type") and "%I:%M %p" or "%H:%M", os.time()),
      ") ",
      Color(151, 255, 211, 255)
    }
  end
  
  for i=1, #message do
    local messageType = type(message[i])
    
    if messageType ~= "table" then
      table.insert(consoleMessage, message[i])
    elseif messageType == "table" then
      if message[i].r and message[i].g and message[i].b and message[i].a then
        table.insert(consoleMessage, message[i])
      elseif message[i].code then
        table.insert(consoleMessage, message[i].code)
      elseif message[i].mentionText then
        table.insert(consoleMessage, message[i].mentionText)
      end
    end
  end
  
  -- Removes double spaces between strings that are seperated by objects
  local iLastStr = 0
  for i=1, #consoleMessage do
    if type(consoleMessage[i]) == "string" then
      if iLastStr > 0 and string.EndsWith(consoleMessage[iLastStr], " ") and string.StartWith(consoleMessage[i], " ") then
        consoleMessage[iLastStr] = string.TrimRight(consoleMessage[iLastStr])
      end
      
      iLastStr = i
    end
  end
  
  MsgC(unpack(consoleMessage))
  MsgN()
end

local function tokenize(str)
  if not speak.prefs:Get("emoji_enabled") then
    return {str}
  end
  
  local lastPos = 1
  local tokens = {}
  
  for pos1,pos2 in str:gmatch("()%:[%w_-]+%:()") do
    local emote = str:sub(pos1,pos2-1)
    
    emote = Emoticons:Get(emote)
    
    if emote then
      local before = str:sub(lastPos,pos1-1)
      if before and before ~= "" then
        tokens[#tokens+1] = before
      end
      
      tokens[#tokens+1] = emote
      
      lastPos = pos2
    end
  end
  
  local after = str:sub(lastPos,-1)
  if after and after ~= "" then
    tokens[#tokens+1] = after
  end
  
  return tokens
end

function speak.ParseChatText(...)
  local message = {}
  
  -- clockwork yelling support, etc
  if Clockwork then
    if(Clockwork.chatBox.multiplier) then
      table.insert(message, CreateSpeakFontMultiplier(Clockwork.chatBox.multiplier))
    end
    Clockwork.chatBox.multiplier = nil
  end
  
  for _, element in pairs({...}) do
    local elementType = type(element)
    
    if elementType == "Player" then
      table.insert(message, CreateSpeakAvatar(element))
      table.insert(message, " ")
      
      local tag = speak.ParseChatText(Tags:Get(element))
      
      if speak.prefs:Get("tag_position") then
        message = table.Add(message, tag[1])
        
        table.insert(message, team.GetColor(element:Team()))
        for _, token in pairs(tokenize(element:Nick())) do
          table.insert(message, token)
        end
      else
        table.insert(message, team.GetColor(element:Team()))
        for _, token in pairs(tokenize(element:Nick())) do
          table.insert(message, token)
        end
        
        message = table.Add(message, tag[1])
      end
    elseif elementType == "Entity" then
      table.insert(message, element:GetClass())
    elseif elementType == "string" then
      local doTokenize = true
      
      for _,v in pairs(player.GetAll()) do
        if string.find(element, string.PatternSafe("@" .. v:Nick())) then
          local iStart, iEnd = string.find(element, string.PatternSafe("@" .. v:Nick()))
          
          local before = string.sub(element, 0, iStart - 1)
          local mention = string.sub(element, iStart, iEnd)
          local after = string.sub(element, iEnd + 1, #element)
          
          table.Add(message, speak.ParseChatText(before, {mentionId = v:SteamID64(), mentionText = mention}, after))
          doTokenize = false
        end
      end
      
      if doTokenize then
        for _, token in pairs(tokenize(element)) do
          table.insert(message, token)
        end
      end
    elseif elementType == "table" then
      table.insert(message, element)
    else
      table.insert(message, tostring(element))
    end
  end
  
  return message
end

function speak.Say(message)
  if Clockwork then
    Clockwork.datastream:Start("PlayerSay", message)
  else
    LocalPlayer():ConCommand("say \"" .. message .. "\"")
  end
end

function speak.SayTeam(message)
  if Clockwork then
    Clockwork.datastream:Start("PlayerSay", message)
  else
    LocalPlayer():ConCommand("say_team \"" .. message .. "\"")
  end
end

function chat.Close()
  if speak.settings:IsVisible() then
    return
  end
  
  speak.view:Close()
  
  hook.Run("FinishChat")
end

function chat.GetChatBoxPos()
  return speak.view:GetPos()
end

function chat.GetChatBoxSize()
  return speak.view:GetSize()
end

function chat.IsOpen()
  return speak.view:IsOpen()
end

function chat.Open(mode)
  if mode == 1 then
    speak.view:Open(false)
  else
    speak.view:Open(true)
  end
  
  hook.Run("StartChat")
end

-- [[ hooks ]]
hook.Add("PlayerBindPress", "speak.PlayerBindPress", function(_, bind, pressed)
  if (bind == "messagemode" or bind == "say") and pressed then
    chat.Open(1)
    return true
  elseif (bind == "messagemode2" or bind == "say_team") and pressed then
    chat.Open(0)
    return true
  end
end)

-- autorefresh
if speak.view then
  speak.view:Remove()
  speak.view = vgui.Create("speak.Chatbox")
else
  hook.Add("Initialize", "Initialize", function()
    include("speak/vgui/speak_radiobutton.lua")
    include("speak/vgui/speak_chatbox.lua")
    include("speak/vgui/speak_settings.lua")
    
    -- initialize the main chat frame
    speak.view = vgui.Create("speak.Chatbox")
    speak.settings = vgui.Create("speak.Settings")
    
    -- we're initializing before policies have been sent so we need to reinitialize after recieving as to hide certain preferences.
    hook.Add("preferences.policyupdate", "speak.preferences.policyupdate", function()
      speak.settings:Remove()
      speak.settings = vgui.Create("speak.Settings")
    end)
    
    concommand.Add("speak_settings", function()
      speak.settings:SetVisible(true)
      speak.settings:MakePopup()
      speak.settings:AlphaTo(255, 0.1, 0, function() end)
      -- or else the chatbox is going to consume clicks
      speak.settings:SetFocusTopLevel(true)
    end)
    
    --[[ Clockwork Compatability ]]
    if Clockwork then
      include("speak/compatability/clockwork_compat.lua")
    end
    
    --[[ DarkRP Compatability ]]
    if DarkRP then
      include("speak/compatability/darkrp_compat.lua")
    end
    
    -- fill in emoji/emoticon autocompletion array
    speak.emojo = {}
    
    for k,_ in pairs(Emoticons.list) do
      speak.emojo[#speak.emojo + 1] = k
    end

    for _,v in pairs(speak.emoji) do
      speak.emojo[#speak.emojo + 1] = v
    end
    
    table.sort(speak.emojo)
  end)
end

-- fired when the DHTML view has initialized
hook.Add("speak.ChatInitialized", "speak.ChatInitialized", function()
  -- update DHTML view's configuration to match our saved preferences
  speak.prefs:FireAllCallbacks()
  
  gameevent.Listen("player_spawn")
  hook.Add("player_spawn", "speak.player_spawn", function()
    if speak and speak.avatarSheet then
      speak.UpdateAvatars()
    end
  end)

  hook.Add("InitPostEntity", "speak.InitPostEntity", function()
    if speak and speak.avatarSheet then
      speak.UpdateAvatars()
    end
  end)
  
  hook.Add("HUDPaint", "speak.HUDPaint", function()
    -- paint the chatbox as a normal HUD element like old chat
    speak.view:PaintManual()
  end)
  
  hook.Add("PreRender", "speak.PreRender", function()
    if not chat.IsOpen() or not gui.IsGameUIVisible() then
      return false
    end
    
    if input.IsKeyDown(KEY_ESCAPE) then
      chat.Close()
      gui.HideGameUI()
    elseif input.IsKeyDown(KEY_BACKQUOTE) and input.LookupBinding("toggleconsole") == "`" then
      gui.HideGameUI()
      speak.view:RequestFocus()
    end
  end)
end)

-- fire notifications
hook.Add("OnPlayerChat", "speak.OnPlayerChat", function(player, text)
  if speak.prefs:Get("notification_enabled") and string.find(text, string.PatternSafe("@" .. LocalPlayer():Nick())) then
    system.FlashWindow()
    notification.AddLegacy("from " .. player:Nick() .. ": " .. text, NOTIFY_GENERIC, speak.prefs:Get("notification_duration"))
    if speak.notificationSounds[speak.prefs:Get("notification_sound")] then
      surface.PlaySound("speak/" .. speak.notificationSounds[speak.prefs:Get("notification_sound")] .. ".mp3")
    end
  end
end)

-- tab completion
hook.Add("OnChatTab", "speak.OnChatTab", function(str)
  str = string.TrimRight(str)
  
  local lastWord
  for word in string.gmatch( str, "[^ ]+" ) do
    lastWord = word
  end
  
  if lastWord ~= nil then
    if speak.lastEmojo ~= nil and speak.lastEmojo >= #speak.emojo then
      speak.lastEmojo = speak.lastEmojo - 1
    end
    
    if speak.lastEmojo then
      local k = speak.emojo[speak.lastEmojo + 1]
      str = string.sub(str, 1, (string.len(lastWord) * -1) - 1)
      str = str .. k
      speak.lastEmojo = speak.lastEmojo + 1
      return str
    end
    
    for _,v in pairs(player.GetAll()) do
      local nickname = "@" .. v:Nick()
      
      if (string.len(lastWord) < string.len(nickname) and string.find(string.lower(nickname), string.lower(lastWord), 0, true) == 1) then
        str = string.sub(str, 1, (string.len(lastWord) * -1) - 1)
        str = str .. nickname .. ": "
        return str
      end
    end
    
    for i=1,#speak.emojo do
      if (string.len(lastWord) < string.len(speak.emojo[i]) and string.find(string.lower(speak.emojo[i]), string.lower(lastWord), 0, true) == 1) then
        str = string.sub(str, 1, (string.len(lastWord) * -1) - 1)
        str = str .. speak.emojo[i]
        speak.lastEmojo = i
        return str
      end
    end
  end
end)

hook.Add("ChatText", "speak.chattext", function(_, _, text, _)
  chat.AddText(text)
end)

-- disable old chat
hook.Add("HUDShouldDraw", "speak.HUDShouldDraw", function(class)
  if class == "CHudChat" then return false end
end)

net.Receive('chat.addtext', function(_)
  chat.AddText(unpack(net.ReadTable()))
end)
