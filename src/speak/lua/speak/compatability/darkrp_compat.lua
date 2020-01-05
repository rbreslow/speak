local function AddToChat(bits)
  local col1 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
  
  local prefixText = net.ReadString()
  local ply = net.ReadEntity()
  ply = IsValid(ply) and ply or nil
  
  if prefixText == "" or not prefixText then
    prefixText = ply:Nick()
    prefixText = prefixText ~= "" and prefixText or ply:SteamName()
  end
  
  local col2 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
  
  local text = net.ReadString()
  local shouldShow
  if text and text ~= "" then
    if IsValid(ply) then
      shouldShow = hook.Call("OnPlayerChat", GAMEMODE, ply, text, false, not ply:Alive(), prefixText, col1, col2)
    end
    
    if shouldShow ~= true then
      if IsValid(ply) then
        local message = {CreateSpeakAvatar(ply), " "}
        
        local tag = speak.ParseChatText(Tags:Get(ply))
        
        if speak.prefs:Get("tag_position") then
          message = table.Add(message, tag[1])
          message = table.Add(message, {col1, prefixText, col2, ": " .. text})
        else
          message = table.Add(message, {col1, prefixText})
          message = table.Add(message, tag[1])
          message = table.Add(message, {col2, ": " .. text})
        end
        
        chat.AddText(unpack(message))
      else
        chat.AddText(col1, prefixText, col2, ": " .. text)
      end
    end
  else
    if IsValid(ply) then
      local message = {CreateSpeakAvatar(ply), " "}
      
      local tag = speak.ParseChatText(Tags:Get(ply))
      
      if speak.prefs:Get("tag_position") then
        message = table.Add(message, tag[1])
        message = table.Add(message, {col1, prefixText})
      else
        message = table.Add(message, {col1, prefixText})
        message = table.Add(message, tag[1])
      end
      
      chat.AddText(unpack(message))
    else
      chat.AddText(col1, prefixText)
    end
  end
  chat.PlaySound()
end
net.Receive("DarkRP_Chat", AddToChat)

hook.Add("DarkRPVarChanged", "speak.DarkRPVarChanged", function(ply, var, old, new)
  if var == "job" then
    -- Put a delay... model hasn't changed yet on the server. Closest hook to when it does change.
    timer.Simple(1, function()
      speak.UpdateAvatars()
    end)
  end
end)
