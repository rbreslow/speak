speak = speak or {}

surface.CreateFont("speak.chattextchanged", {
    font = "Roboto",
    extended = false,
    size = 48,
    weight = 700,
    shadow = true,
})

--[[ Classes ]]
include("cl_avatarsheet.lua")
include("cl_emoticons.lua")
include("sh_globals.lua")
include("cl_locale.lua")
include("cl_modelsheet.lua")
include("cl_tags.lua")

--[[ Base64 decoding (http://lua-users.org/wiki/BaseSixtyFour) ]]
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function b64dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

--[[ Static References ]]
speak.prefs = Preferences("speak")

--[[ General Preferences ]]
speak.prefs:DefineBoolean("tag_position", true, function(value) end)

--[[ Emoji Preferences ]]
speak.prefs:DefineNumber("emoji_pack", 1, function(value)
    value = math.Clamp(value, 1, 4)

    local pack = "apple"

    if value == 2 then
        pack = "google"
    elseif value == 3 then
        pack = "twitter"
    elseif value == 4 then
        pack = "emojione"
    end

    speak.view:SetStringProperty("emojiSet", pack)
end)
speak.prefs:DefineBoolean("emoji_enabled", true, function(value) end)

--[[ Timestamp Preferences ]]
speak.prefs:DefineBoolean("timestamps_enabled", true, function(value) end)
speak.prefs:DefineBoolean("timestamps_type", true, function(value) end)
speak.prefs:DefineTable("timestamps_color", Color(114, 188, 212), function(value) end)

--[[ Chat Positioning Preferences ]]
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

--[[ Avatar Preferences ]]
speak.prefs:DefineBoolean("avatars_enabled", true, function(value)
    speak.view:SetBooleanProperty("avatarEnabled", value)
end)
speak.prefs:DefineBoolean("avatars_type", false, function(value)
    speak.avatarSheet = value and ModelSheet() or AvatarSheet()

    speak.UpdateAvatars()
end)

--[[ Font Preferences ]]
speak.prefs:DefineString("font_name", "Roboto", function(value)
    speak.view:SetStringProperty("fontName", value)
end)
speak.prefs:DefineNumber("font_size", 12, function(value)
    speak.view:SetRawProperty("fontSize", value)
end)
speak.prefs:DefineNumber("font_weight", 500, function(value)
    speak.view:SetRawProperty("fontWeight", value)
end)
speak.prefs:DefineBoolean("font_border_type", true, function(value)
    speak.view:SetBooleanProperty("fontBorderType", value)
end)
speak.prefs:DefineNumber("font_border_blur", 0.13, function(value)
    speak.view:SetRawProperty("fontBorderBlur", value)
end)
speak.prefs:DefineNumber("font_border_opacity", 1, function(value)
    speak.view:SetRawProperty("fontBorderOpacity", value)
end)

speak.prefs:DefineNumber("notification_sound", 1, function(value) end)
speak.prefs:DefineNumber("notification_duration", 10, function(value) end)
speak.prefs:DefineBoolean("notification_enabled", true, function(value) end)

speak.Notifications = {
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

speak.prefs:DefineBoolean("show_typing", true, function(value) end)

function speak.UpdateAvatars()
    speak.avatarSheet:Update(function(data)
        speak.view:SetStringProperty("avatarSheet", data)
    end)
end

--[[ Chat Overrides ]]
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

        if not (messageType == "table") then
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

    -- This little beauty removes double spaces between strings that are seperated by objects... Acecool couldn't figure it out :)
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
function speak.ParseChatText(...)
    -- Tokenization basic logic by SwadicalRag in gLua chatroom
    local function tokenize(str)
        if not speak.prefs:Get("emoji_enabled") then
            return {str}
        end

        local lastPos = 1
        local tokens = {}

        for pos1,pos2 in str:gmatch("()%:%w+%:()") do
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

    local message = {}

    -- Clockwork yelling support, etc
    if Clockwork then
        if(Clockwork.chatBox.multiplier) then
            table.insert(message, CreateSpeakFontMultiplier(Clockwork.chatBox.multiplier))
        end
        Clockwork.chatBox.multiplier = nil
    end;

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
function chat.Open(mode)
    if mode == 1 then
        speak.view:Open(false)
    else
        speak.view:Open(true)
    end

    hook.Run("StartChat")
end
function chat.IsOpen()
    return speak.view:IsOpen()
end
function chat.Close()
    net.Start("speak.chattextchanged")
    net.WriteString("")
    net.SendToServer()

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

--[[ Hooks ]]
hook.Add("PlayerBindPress", "speak.PlayerBindPress", function(_, bind, pressed)
    if (bind == "messagemode" or bind == "say") and pressed then
        chat.Open(1)
        return true
    elseif (bind == "messagemode2" or bind == "say_team") and pressed then
        chat.Open(0)
        return true
    end
end)
-- Autorefresh support for initialization
if speak.view then
    speak.view = vgui.Create("speak.ChatBox")
else
    hook.Add("Initialize", "Initialize", function()
        --[[ vgui ]]
        include("speak/vgui/rbreslow_radiobutton.lua")
        include("speak/vgui/speak_chatbox.lua")
        include("speak/vgui/speak_settings.lua")

        -- Initialize the main chat frame
        speak.view = vgui.Create("speak.ChatBox")
        speak.settings = vgui.Create("speak.Settings")

        -- We're initializing before policies have been sent so we need to reinitialize after recieving as to hide certain preferences.
        hook.Add("preferences.policyupdate", "speak.preferences.policyupdate", function()
            speak.settings:Remove()
            speak.settings = vgui.Create("speak.Settings")
        end)

        concommand.Add("speak_settings", function()
            speak.settings:SetVisible(true)
            speak.settings:MakePopup()
            speak.settings:AlphaTo(255, 0.1, 0, function() end)
        end)

        --[[ Clockwork Compatability ]]
        if Clockwork then
            include("speak/compatability/clockwork_compat.lua")
        end

        --[[ DarkRP Compatability ]]
        if DarkRP then
            include("speak/compatability/darkrp_compat.lua")
        end

        speak.kill_me = {}

        for k,v in pairs(Emoticons.list) do
            speak.kill_me[#speak.kill_me + 1] = k
        end

        for k,v in pairs(Emoticons.emoji) do
            speak.kill_me[#speak.kill_me + 1] = v
        end

        table.sort(speak.kill_me)
    end)
end
hook.Add("speak.ChatInitialized", "speak.ChatInitialized", function()
    -- Update the chat frame's configuration to match our saved preferences
    speak.prefs:FireAllCallbacks()

    gameevent.Listen( "player_spawn" )
    hook.Add("player_spawn", "speak.player_spawn", function()
        if speak and speak.avatarSheet then
            speak.UpdateAvatars()
        end
    end)
    hook.Add("OnEntityCreated", "speak.OnEntityCreated", function(ent)
        if ent:IsPlayer() and speak and speak.avatarSheet then
            speak.UpdateAvatars()
        end
    end)
    hook.Add("HUDPaint", "speak.HUDPaint", function()
        -- Paint the chatbox as a normal HUD element like old chat
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
            speak.view:ShitFocus()
        end
    end)
end)
hook.Add("OnPlayerChat", "speak.onPlayerChat", function(player, text)
    if speak.prefs:Get("notification_enabled") and string.find(text, string.PatternSafe("@" .. LocalPlayer():Nick())) then
        local iStart, _ = string.find(text, string.PatternSafe("@" .. LocalPlayer():Nick()))

        system.FlashWindow()
        notification.AddLegacy("from " .. player:Nick() .. ": " .. text, NOTIFY_GENERIC, speak.prefs:Get("notification_duration"))
        if speak.Notifications[speak.prefs:Get("notification_sound")] then
            surface.PlaySound("speak/" .. speak.Notifications[speak.prefs:Get("notification_sound")] .. ".mp3")
        end
    end
end)

--[[ BEGIN ZERF ]]
hook.Add("OnChatTab", "speak.OnChatTab", function(str)
    str = string.TrimRight(str)

    local LastWord
    for word in string.gmatch( str, "[^ ]+" ) do
        LastWord = word
    end

    if LastWord ~= nil then
        if speak.lastemojo ~= nil and speak.lastemojo >= #speak.kill_me then
           speak.lastemojo = speak.lastemojo - 1
        end

        if speak.lastemojo then
            local k = speak.kill_me[speak.lastemojo + 1]
            str = string.sub( str, 1, ( string.len( LastWord ) * -1 ) - 1 )
            str = str .. k
            speak.lastemojo = speak.lastemojo + 1
            return str
        end

        for k, v in pairs( player.GetAll() ) do

            local nickname = "@" .. v:Nick()

            if ( string.len( LastWord ) < string.len( nickname ) and string.find( string.lower( nickname ), string.lower( LastWord ), 0, true ) == 1 ) then

                str = string.sub( str, 1, ( string.len( LastWord ) * -1 ) - 1 )
                str = str .. nickname .. ": "
                return str

            end
        end

        for i=1,#speak.kill_me do
            if ( string.len( LastWord ) < string.len( speak.kill_me[i] ) and string.find( string.lower( speak.kill_me[i] ), string.lower( LastWord ), 0, true ) == 1 ) then
                str = string.sub( str, 1, ( string.len( LastWord ) * -1 ) - 1 )
                str = str .. speak.kill_me[i]
                speak.lastemojo = i
                return str
            end
        end

    end

end)
--[[ END ZERF]]
hook.Add("ChatTextChanged", "speak.ChatTextChanged", function(str)
    net.Start("speak.chattextchanged")
    net.WriteString(str)
    net.SendToServer()
end)
hook.Add("PostDrawTranslucentRenderables", "speak.PostDrawTranslucentRenderables", function(_, _)
    if not speak.prefs:Get("show_typing") then return end

    for _, player in pairs(player.GetAll()) do
        local str = player:GetNW2String("chattext", "")
        local BoneIndx = player:LookupBone("ValveBiped.Bip01_Head1")

        if --[[player ~= LocalPlayer() and]] str ~= "" and BoneIndx ~= nil then
            local BonePos, BoneAng = player:GetBonePosition( BoneIndx )
            local pos = BonePos + Vector(0,0,15) -- Place above head bone
            local eyeang = LocalPlayer():EyeAngles().y - 90 -- Face upwards
            local ang = Angle( 0, eyeang, 90 )

            cam.Start3D2D(pos, ang, .1)
            surface.SetFont("speak.chattextchanged")
            surface.SetTextColor(Color(255, 255, 255, 255))
            local w, _ = surface.GetTextSize(str)
            surface.SetTextPos(-w / 2, 0)
            render.PushFilterMin(TEXFILTER.ANISOTROPIC)
            render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            surface.DrawText(str)
            render.PopFilterMin()
            render.PopFilterMag()
            cam.End3D2D()
        end
    end
end)
hook.Add("ChatText", "speak.chattext", function(_, _, text, _)
    chat.AddText(text)
end)
hook.Add("HUDShouldDraw", "speak.HUDShouldDraw", function(class)
    -- Disable old chat
    if class == "CHudChat" then return false end
end)
net.Receive('chat.addtext', function(_)
    chat.AddText(unpack(net.ReadTable()))
end)
