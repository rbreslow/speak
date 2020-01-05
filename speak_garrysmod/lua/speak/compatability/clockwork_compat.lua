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
            ") "
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

hook.Remove("PlayerBindPress", "Clockwork.chatBox:PlayerBindPress")

Clockwork.chatBox.Paint = function() end

-- A function to add a message to the chat box.
function Clockwork.chatBox:Add(filtered, icon, ...)
    if (ScrW() == 160 or ScrH() == 27) then
        return;
    end;

    if (!filtered) then
    local maximumLines = math.Clamp(CW_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
    local colorWhite = Clockwork.option:GetColor("white");
    local curTime = UnPredictedCurTime();
    local message = {
        timeFinish = curTime + 11,
        timeStart = curTime,
        timeFade = curTime + 10,
        spacing = 0,
        alpha = 255,
        lines = 1,
        icon = icon
    };

    if (self.multiplier) then
        message.multiplier = self.multiplier;
        --self.multiplier = nil;
    end;


    local curOnHover = nil;
    local curColor = nil;
    local text = {...};

    if (CW_CONVAR_SHOWTIMESTAMPS:GetInt() == 1) then
        local timeInfo = "("..os.date("%H:%M")..") ";
        local color = Color(150, 150, 150, 255);


        if (CW_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
            timeInfo = "("..string.lower(os.date("%I:%M%p"))..") ";
        end;

        if (text) then
            table.insert(text, 1, color);
            table.insert(text, 2, timeInfo);
        else
            text = {timeInfo, color};
        end;
    end;


    if (text) then
        message.text = {};

        for k, v in pairs(text) do
            if (type(v) == "string" or type(v) == "number" or type(v) == "boolean") then
                Clockwork.chatBox:WrappedText(
                    nil, message, curColor or colorWhite, tostring(v), curOnHover
                );
                curColor = nil;
                curOnHover = nil;
            elseif (type(v) == "function") then
                curOnHover = v;
            elseif (type(v) == "Player") then
                Clockwork.chatBox:WrappedText(
                    nil, message, cwTeam.GetColor(v:Team()), v:Name(), curOnHover
                );
                curColor = nil;
                curOnHover = nil;
            elseif (type(v) == "table") then
                curColor = Color(v.r or 255, v.g or 255, v.b or 255);
            end;
        end;
    end;


    if (self.historyPos == #self.historyMsgs) then
        self.historyPos = #self.historyMsgs + 1;
    end;

    self.historyMsgs[#self.historyMsgs + 1] = message;

    if (#self.messages == maximumLines) then
        table.remove(self.messages, maximumLines);
    end;

    if icon == nil then
        chat.AddText(...)
    else
        chat.AddText(CreateSpeakImage(icon), " ", ...)
    end

    Clockwork.option:PlaySound("tick");
    end;
end

-- A function to decode a message.
function Clockwork.chatBox:Decode(speaker, name, text, data, class, multiplier)
    local filtered = nil;
    local filter = nil;
    local icon = nil;

    if (!IsValid(Clockwork.Client)) then
    return;
    end;

    if (self.classes[class]) then
        filter = self.classes[class].filter;
    elseif (class == "pm" or class == "ooc"
            or class == "roll" or class == "looc"
            or class == "priv") then
        filtered = (CW_CONVAR_SHOWOOC:GetInt() == 0);
        filter = "ooc";
    else
        filtered = (CW_CONVAR_SHOWIC:GetInt() == 0);
        filter = "ic";
    end;

    text = Clockwork.kernel:Replace(text, " ' ", "'");

    if (IsValid(speaker)) then
        if (!Clockwork.kernel:IsChoosingCharacter()) then
        if (speaker:Name() != "") then
        local unrecognised = false;
        local classIndex = speaker:Team();
        local classColor = cwTeam.GetColor(classIndex);
        local focusedOn = false;

        if (speaker:IsSuperAdmin()) then
            icon = "icon16/shield.png";
        elseif (speaker:IsAdmin()) then
            icon = "icon16/star.png";
        elseif (speaker:IsUserGroup("operator")) then
            icon = "icon16/emoticon_smile.png";
        else
            local faction = speaker:GetFaction();

            if (faction and Clockwork.faction.stored[faction]) then
                if (Clockwork.faction.stored[faction].whitelist) then
                    icon = "icon16/add.png";
                end;
            end;

            if (!icon) then
            icon = "icon16/user.png";
            end;
        end;

        if (!Clockwork.player:DoesRecognise(speaker, RECOGNISE_TOTAL) and filter == "ic") then
        unrecognised = true;
        end;

        local trace = Clockwork.player:GetRealTrace(Clockwork.Client);

        if (trace and trace.Entity and IsValid(trace.Entity) and trace.Entity == speaker) then
            focusedOn = true;
        end;

        local info = {
            unrecognised = unrecognised,
            shouldHear = Clockwork.player:CanHearPlayer(Clockwork.Client, speaker),
            multiplier = multiplier,
            focusedOn = focusedOn,
            filtered = filtered,
            speaker = speaker,
            visible = true;
            filter = filter,
            class = class,
            icon = icon,
            name = name,
            text = text,
            data = data
        };

        Clockwork.plugin:Call("ChatBoxAdjustInfo", info);
        Clockwork.chatBox:SetMultiplier(info.multiplier);

        if (info.visible) then
            if (info.filter == "ic") then
                if (!Clockwork.Client:Alive()) then
                return;
                end;
            end;


            local avatar = {CreateSpeakAvatar(info.speaker), " "}

            if (info.unrecognised) then
                local unrecognisedName, usedPhysDesc = Clockwork.player:GetUnrecognisedName(info.speaker);

                if (usedPhysDesc and string.len(unrecognisedName) > 24) then
                    unrecognisedName = string.sub(unrecognisedName, 1, 21).."...";
                end;

                info.name = "["..unrecognisedName.."]";
                avatar = {"", ""}
            end;

            if (self.classes[info.class]) then
                self.classes[info.class].Callback(info);
            elseif (info.class == "radio_eavesdrop") then
                if (info.shouldHear) then
                    local color = Color(255, 255, 175, 255);

                    if (info.focusedOn) then
                        color = Color(175, 255, 175, 255);
                    end;

                    Clockwork.chatBox:Add(info.filtered, nil, color, avatar[1], avatar[2], info.name.." radios in \""..info.text.."\"");
                end;
            elseif (info.class == "whisper") then
                if (info.shouldHear) then
                    local color = Color(255, 255, 175, 255);

                    if (info.focusedOn) then
                        color = Color(175, 255, 175, 255);
                    end;

                    Clockwork.chatBox:Add(info.filtered, nil, color, avatar[1], avatar[2], info.name.." whispers \""..info.text.."\"");
                end;
            elseif (info.class == "event") then
                Clockwork.chatBox:Add(info.filtered, nil, Color(200, 100, 50, 255), avatar[1], avatar[2], info.text);
            elseif (info.class == "radio") then
                Clockwork.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), avatar[1], avatar[2], info.name.." radios in \""..info.text.."\"");
            elseif (info.class == "yell") then
                local color = Color(255, 255, 175, 255);

                if (info.focusedOn) then
                    color = Color(175, 255, 175, 255);
                end;
                Clockwork.chatBox:Add(info.filtered, nil, color, avatar[1], avatar[2], info.name.." yells \""..info.text.."\"");
            elseif (info.class == "chat") then
                Clockwork.chatBox:Add(info.filtered, nil, classColor, avatar[1], avatar[2], info.name, ": ", info.text, nil, info.filtered);
            elseif (info.class == "looc") then
                Clockwork.chatBox:Add(info.filtered, nil, Color(225, 50, 50, 255), CreateSpeakAvatar(info.speaker), " [LOOC] ", Color(255, 255, 150, 255), info.name..": "..info.text);
            elseif (info.class == "priv") then
                Clockwork.chatBox:Add(info.filtered, nil, Color(255, 200, 50, 255), avatar[1], avatar[2], "@"..info.data.userGroup.." ", classColor, info.name, ": ", info.text);
            elseif (info.class == "roll") then
                if (info.shouldHear) then
                    Clockwork.chatBox:Add(info.filtered, nil, Color(150, 75, 75, 255),  avatar[1], avatar[2],"** "..info.name.." "..info.text);
                end;
            elseif (info.class == "ooc") then
                Clockwork.chatBox:Add(info.filtered, info.icon, Color(225, 50, 50, 255), avatar[1], avatar[2], "[OOC] ", classColor, info.name, ": ", info.text);
            elseif (info.class == "pm") then
                Clockwork.chatBox:Add(info.filtered, nil, "[PM] ", Color(125, 150, 75, 255), avatar[1], avatar[2], info.name..": "..info.text);
                surface.PlaySound("hl1/fvox/bell.wav");
            elseif (info.class == "me") then
                local color = Color(255, 255, 175, 255);

                if (info.focusedOn) then
                    color = Color(175, 255, 175, 255);
                end;

                if (string.sub(info.text, 1, 1) == "'") then
                    Clockwork.chatBox:Add(info.filtered, nil, color, avatar[1], avatar[2], "** "..info.name..info.text);
                else
                    Clockwork.chatBox:Add(info.filtered, nil, color, avatar[1], avatar[2], "** "..info.name.." "..info.text);
                end;
            elseif (info.class == "it") then
                local color = Color(255, 255, 175, 255);

                if (info.focusedOn) then
                    color = Color(175, 255, 175, 255);
                end;

                Clockwork.chatBox:Add(info.filtered, nil, color, avatar[1], avatar[2], "** "..info.text);
            elseif (info.class == "ic") then
                if (info.shouldHear) then
                    local color = Color(255, 255, 150, 255);

                    if (info.focusedOn) then
                        color = Color(175, 255, 150, 255);
                    end;

                    Clockwork.chatBox:Add(info.filtered, nil, avatar[1], avatar[2], color, info.name.." says \""..info.text.."\"");
                end;
            end;
        end;
        end;
        end;
    else
        if (name == "Console" and class == "chat") then
            icon = "icon16/shield.png";
        end;


        local info = {
            multiplier = multiplier,
            filtered = filtered,
            visible = true;
            filter = filter,
            class = class,
            icon = icon,
            name = name,
            text = text,
            data = data
        };

        Clockwork.plugin:Call("ChatBoxAdjustInfo", info);
        Clockwork.chatBox:SetMultiplier(info.multiplier);

        if (!info.visible) then return; end;

        if (self.classes[info.class]) then
            self.classes[info.class].Callback(info);
        elseif (info.class == "notify_all") then
            if (Clockwork.kernel:GetNoticePanel()) then
                Clockwork.kernel:AddCinematicText(info.text, Color(255, 255, 255, 255), 32, 6, Clockwork.option:GetFont("menu_text_tiny"), true);
            end;

            local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;

            if (string.sub(info.text, -1) == "!") then
                Clockwork.chatBox:Add(filtered, "icon16/error.png", Color(200, 175, 200, 255), info.text);
            else
                Clockwork.chatBox:Add(filtered, "icon16/comment.png", Color(125, 150, 175, 255), info.text);
            end;
        elseif (info.class == "disconnect") then
            local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;

            Clockwork.chatBox:Add(filtered, "icon16/user_delete.png", Color(200, 150, 200, 255), info.text);
        elseif (info.class == "notify") then
            if (Clockwork.kernel:GetNoticePanel()) then
                Clockwork.kernel:AddCinematicText(info.text, Color(255, 255, 255, 255), 32, 6, Clockwork.option:GetFont("menu_text_tiny"), true);
            end;

            local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;

            if (string.sub(info.text, -1) == "!") then
                Clockwork.chatBox:Add(filtered, "icon16/error.png", Color(200, 175, 200, 255), info.text);
            else
                Clockwork.chatBox:Add(filtered, "icon16/comment.png", Color(175, 200, 255, 255), info.text);
            end;
        elseif (info.class == "connect") then
            local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
            Clockwork.chatBox:Add(filtered, "icon16/user_add.png", Color(150, 150, 200, 255), info.text);
        elseif (info.class == "chat") then
            Clockwork.chatBox:Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[OOC] ", Color(150, 150, 150, 255), name, ": ", info.text);
        else
            local yellowColor = Color(255, 255, 150, 255);
            local blueColor = Color(125, 150, 175, 255);
            local redColor = Color(200, 25, 25, 255);
            local filtered = (CW_CONVAR_SHOWSERVER:GetInt() == 0) or info.filtered;
            local prefix;

            Clockwork.chatBox:Add(filtered, nil, yellowColor, info.text);
        end;
    end;
end;

Clockwork.datastream:Hook("SharedVar", function(data)
    if data.key == "Model" then
       speak.UpdateAvatars()
    end
end)