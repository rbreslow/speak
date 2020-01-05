surface.CreateFont("speak.Settings.Heading", {
    font = "Trebuchet MS",
    extended = false,
    size = 20,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont("speak.Settings.Paragraph", {
    font = "Tahoma",
    extended = false,
    size = 14,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

local PANEL = {}

function PANEL:Init()
    local i18n = speak.i18n

    self:SetTitle("Settings")

    self:SetSize(384, 540)
    self:Center()
    self:SetAlpha(0)

    self:SetDeleteOnClose(false)

    self:SetSkin("Default")

    local root = vgui.Create("DPropertySheet", self)
    self.root = root
    root:DockPadding(8, 0, 8, 8)
    root:Dock(FILL)

    local panel = vgui.Create("DPanel", root)
    panel:Dock(FILL)

    local messageDisplay = vgui.Create("DScrollPanel", panel)

    local function padding(parent)
        local panel = vgui.Create("DPanel", parent)
        panel:Dock(TOP)
        panel:SetSize(root:GetPadding(), root:GetPadding())
        panel:SetPaintBackground(false)
    end

    local function paddingLeft(parent)
        local panel = vgui.Create("DPanel", parent)
        panel:Dock(LEFT)
        panel:SetSize(root:GetPadding(), root:GetPadding())
        panel:SetPaintBackground(false)
    end

    local function heading(name)
        local heading = vgui.Create("DLabel", messageDisplay)
        heading:SetText(name)
        heading:SetFont("speak.Settings.Heading")
        heading:SetColor(Color(68, 68, 68, 255))
        heading:Dock(TOP)
        heading:DockMargin(8, 0, 8, 0)
    end

    local function checkRow(text)
        local row = vgui.Create("DPanel", messageDisplay)
        row:SetPaintBackground(false)
        row:Dock(TOP)
        row:DockPadding(8, 0, 8, 0)

        local buttonContainer = vgui.Create("DPanel", row);
        buttonContainer:SetPaintBackground(false)
        buttonContainer:SetWide(15)
        buttonContainer:Dock(LEFT)

        local button = vgui.Create( "DCheckBox", buttonContainer)
        button:CenterVertical()
        button:SetValue(false)

        paddingLeft(row)

        local testLabel = vgui.Create("DLabel", row)
        testLabel:SetText(text)
        testLabel:SetTextColor(Color(68, 68, 68, 255))

        testLabel:Dock(LEFT)
        testLabel:SetFont("speak.Settings.Paragraph")

        testLabel:SizeToContents()

        row.OnMousePressed = function(self, keyCode)
            if keyCode == MOUSE_LEFT then
                button:DoClick()
            end
        end

        return button
    end

    local function emojiRow(rowName, short)
        local row = vgui.Create("DPanel", messageDisplay)
        row:SetPaintBackground(false)
        row:Dock(TOP)
        row:DockPadding(8, 0, 8, 0)

        local emojiPreview = vgui.Create("DHTML", row)
        emojiPreview:Dock(RIGHT)
        emojiPreview:SetWide(108)

        emojiPreview:SetHTML([[
			<style>html, body { overflow: hidden; margin: 0; padding: 0; width: 512px; -webkit-user-select: none; user-select:none; cursor: default; } img { margin: 0; padding: 0; width: 24px; height: 24px; }</style>

			<img unselectable="on"
 onselectstart="return false;"
 onmousedown="return false;" src='https://cdn.jsdelivr.net/npm/emoji-datasource-]] .. short .. [[@4.1.0/img/]] .. short .. [[/64/1f642.png'></img>
			<img unselectable="on"
 onselectstart="return false;"
 onmousedown="return false;" src="https://cdn.jsdelivr.net/npm/emoji-datasource-]] .. short .. [[@4.1.0/img/]] .. short .. [[/64/1f44d.png"></img>
			<img unselectable="on"
 onselectstart="return false;"
 onmousedown="return false;" src="https://cdn.jsdelivr.net/npm/emoji-datasource-]] .. short .. [[@4.1.0/img/]] .. short .. [[/64/1f680.png"></img>
			<img unselectable="on"
 onselectstart="return false;"
 onmousedown="return false;" src="https://cdn.jsdelivr.net/npm/emoji-datasource-]] .. short .. [[@4.1.0/img/]] .. short .. [[/64/1f4a9.png"></img>
		]])

        local buttonContainer = vgui.Create("DPanel", row)
        buttonContainer:SetPaintBackground(false)
        buttonContainer:SetWide(15)
        buttonContainer:Dock(LEFT)

        local button = vgui.Create("speak.RadioButton", buttonContainer)
        button:CenterVertical()

        paddingLeft(row)

        local label = vgui.Create("DLabel", row)

        label:Dock(LEFT)

        label:SetText(rowName)
        label:SetTextColor(Color(68, 68, 68, 255))
        label:SetFont("speak.Settings.Paragraph")

        label:SizeToContents()

        row.OnMousePressed = function(self, keyCode)
            if keyCode == MOUSE_LEFT then
                button:DoClick()
            end
        end

        return button
    end

    local function radioRow(rowName, parent)
        local row = vgui.Create("DPanel", parent)
        row:SetPaintBackground(false)
        row:Dock(TOP)
        row:DockPadding(8, 0, 8, 0)

        local buttonContainer = vgui.Create("DPanel", row)
        buttonContainer:SetPaintBackground(false)
        buttonContainer:SetWide(15)
        buttonContainer:Dock(LEFT)

        local button = vgui.Create("speak.RadioButton", buttonContainer)
        button:CenterVertical()

        paddingLeft(row)

        local label = vgui.Create("DLabel", row)

        label:Dock(LEFT)

        label:SetText(rowName)
        label:SetTextColor(Color(68, 68, 68, 255))
        label:SetFont("speak.Settings.Paragraph")

        label:SizeToContents()

        row.OnMousePressed = function(self, keyCode)
            if keyCode == MOUSE_LEFT then
                button:DoClick()
            end
        end

        return button
    end

    --[[ Begin: Avatar Style ]]
    padding(messageDisplay)
    heading(i18n:Translate("AVATAR_STYLE"))

    local split = vgui.Create( "DIconLayout", messageDisplay)
    split:Dock(TOP)
    split:SetSpaceX(root:GetPadding())

    local left = vgui.Create("DPanel", split)
    left:SetPaintBackground(false)
    left:SetSize(self:GetWide() / 2 - root:GetPadding() * 2 - 1, left:GetTall() * 2)

    local group = {
        radioRow(i18n:Translate("STEAM_AVATAR"), left),
        radioRow(i18n:Translate("PLAYER_MODEL"), left)
    }

    for i=1,#group do
        group[i]:SetGroup(group)
    end

    local right = vgui.Create("DPanel", split)
    right:SetPaintBackground(false)
    right:SetSize(self:GetWide() / 2 - root:GetPadding() * 2 - 1, right:GetTall() * 2)

    local avatarImage, label

    if speak.prefs:Get("avatars_type") then
        group[2]:SetActive(true)

        avatarImage = vgui.Create("DModelPanel", right)
        avatarImage:Dock(LEFT)
        avatarImage:SetSize(64, 64)
        avatarImage:SetModel("models/buildables/teleporter.mdl")
        avatarImage.Entity:SetModel("models/Humans/Group01/male_07.mdl")

        local iSeq = avatarImage.Entity:LookupSequence("walk_all")
        if iSeq <= 0 then iSeq = avatarImage.Entity:LookupSequence("WalkUnarmed_all") end
        if iSeq <= 0 then iSeq = avatarImage.Entity:LookupSequence("walk_all_moderate") end
        if iSeq > 0 then avatarImage.Entity:ResetSequence(iSeq) end

        avatarImage:SetFOV(10)

        avatarImage:SetCamPos(Vector(0, 60, avatarImage.Entity:OBBCenter( ).z));

        local angle_front = Angle(0, 90, 0);

        avatarImage.__LayoutEntity = avatarImage.__LayoutEntity or avatarImage.LayoutEntity;

        function avatarImage:LayoutEntity(ent)
            self.__LayoutEntity(self, ent);

            ent:SetAngles(angle_front);
            ent:SetPos(Vector(0, 0, -32))

            avatarImage:SetLookAt(avatarImage.Entity:OBBCenter());
        end

        paddingLeft(right)

        label = vgui.Create("DLabel", right)
        label:Dock(LEFT)
        label:SetText("garry")
        label:SetTextColor(Color(255, 255, 100, 255))
        label:SetFont("ChatFont")
    else
        group[1]:SetActive(true)

        avatarImage = vgui.Create("AvatarImage", right)
        avatarImage:Dock(LEFT)
        avatarImage:SetSize(right:GetTall(), right:GetTall())
        avatarImage:SetSteamID("76561197960279927", 64)

        paddingLeft(right)

        label = vgui.Create("DLabel", right)
        label:Dock(LEFT)
        label:SetText("garry")
        label:SetTextColor(Color(255, 255, 100, 255))
        label:SetFont("ChatFont")
    end

    group[1].OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("avatars_type", false)

            for i=1, #right:GetChildren() do
                right:GetChildren()[i]:Remove()
            end

            avatarImage = vgui.Create("AvatarImage", right)
            avatarImage:Dock(LEFT)
            avatarImage:SetSize(right:GetTall(), right:GetTall())
            avatarImage:SetSteamID("76561197960279927", 64)

            paddingLeft(right)

            label = vgui.Create("DLabel", right)
            label:Dock(LEFT)
            label:SetText("garry")
            label:SetTextColor(Color(255, 255, 100, 255))
            label:SetFont("ChatFont")
        end
    end

    group[2].OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("avatars_type", true)

            for i=1, #right:GetChildren() do
                right:GetChildren()[i]:Remove()
            end

            avatarImage = vgui.Create("DModelPanel", right)
            avatarImage:Dock(LEFT)
            avatarImage:SetSize(right:GetTall(), right:GetTall())
            avatarImage:SetModel("models/buildables/teleporter.mdl")
            avatarImage.Entity:SetModel("models/Humans/Group01/male_07.mdl")

            local iSeq = avatarImage.Entity:LookupSequence("walk_all")
            if iSeq <= 0 then iSeq = avatarImage.Entity:LookupSequence("WalkUnarmed_all") end
            if iSeq <= 0 then iSeq = avatarImage.Entity:LookupSequence("walk_all_moderate") end
            if iSeq > 0 then avatarImage.Entity:ResetSequence(iSeq) end

            avatarImage:SetFOV(10)

            avatarImage:SetCamPos(Vector(0, 60, avatarImage.Entity:OBBCenter( ).z));

            local angle_front = Angle(0, 90, 0);

            avatarImage.__LayoutEntity = avatarImage.__LayoutEntity or avatarImage.LayoutEntity;

            function avatarImage:LayoutEntity(ent)
                self.__LayoutEntity(self, ent);

                ent:SetAngles(angle_front);
                ent:SetPos(Vector(0, 0, -32))

                avatarImage:SetLookAt(avatarImage.Entity:OBBCenter());
            end

            paddingLeft(right)

            label = vgui.Create("DLabel", right)
            label:Dock(LEFT)
            label:SetText("garry")
            label:SetTextColor(Color(255, 255, 100, 255))
            label:SetFont("ChatFont")
        end
    end

    padding(messageDisplay)
    --[[ End: Avatar Style ]]

    local check = checkRow(i18n:Translate("AVATARS_ENABLED"))
    check:SetValue(speak.prefs:Get("avatars_enabled"))
    check.OnChange = function(self, value)
        speak.prefs:SetBoolean("avatars_enabled", value)
    end

    padding(messageDisplay)

    --[[ Begin: Tag Position ]]
    heading(i18n:Translate("TAG_POSITION"))

    split = vgui.Create( "DIconLayout", messageDisplay)
    split:Dock(TOP)
    split:SetSpaceX(root:GetPadding())

    left = vgui.Create("DPanel", split)
    left:SetPaintBackground(false)
    left:SetSize(self:GetWide() / 2 - root:GetPadding() * 2 - 1, left:GetTall() * 2)

    group = {
        radioRow(i18n:Translate("LEFT"), left),
        radioRow(i18n:Translate("RIGHT"), left)
    }

    for i=1,#group do
        group[i]:SetGroup(group)
    end

    local rightTags = vgui.Create("DPanel", split)
    rightTags:SetPaintBackground(false)
    rightTags:SetSize(self:GetWide() / 2 - root:GetPadding() * 2 - 1, rightTags:GetTall() * 2)

    local tag1 = vgui.Create("DLabel", rightTags)
    tag1:Dock(LEFT)
    tag1:SetFont("ChatFont")

    local tag2 = vgui.Create("DLabel", rightTags)
    tag2:Dock(LEFT)
    tag2:SetFont("ChatFont")

    group[1].OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("tag_position", true)

            tag1:SetText("(" .. i18n:Translate("ADMIN") .. ")")
            tag1:SetTextColor(Color(255, 100, 100, 255))
            tag1:SizeToContents()

            tag2:SetText(" garry ")
            tag2:SetTextColor(Color(255, 255, 100, 255))
            tag2:SizeToContents()
        end
    end

    group[2].OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("tag_position", false)

            tag2:SetText("(" .. i18n:Translate("ADMIN") .. ")")
            tag2:SetTextColor(Color(255, 100, 100, 255))
            tag2:SizeToContents()

            tag1:SetText("garry ")
            tag1:SetTextColor(Color(255, 255, 100, 255))
            tag1:SizeToContents()
        end
    end

    if speak.prefs:Get("tag_position") then
        group[1]:SetActive(true)

        tag1:SetText("(" .. i18n:Translate("ADMIN") .. ")")
        tag1:SetTextColor(Color(255, 100, 100, 255))
        tag1:SizeToContents()

        tag2:SetText(" garry ")
        tag2:SetTextColor(Color(255, 255, 100, 255))
        tag2:SizeToContents()
    else
        group[2]:SetActive(true)

        tag2:SetText("(" .. i18n:Translate("ADMIN") .. ")")
        tag2:SetTextColor(Color(255, 100, 100, 255))
        tag2:SizeToContents()

        tag1:SetText("garry ")
        tag1:SetTextColor(Color(255, 255, 100, 255))
        tag1:SizeToContents()
    end

    padding(messageDisplay)
    --[[ End: Tag Position ]]

    --[[ Begin: Display Options ]]
    heading(i18n:Translate("DISPLAY_OPTIONS"))
    padding(messageDisplay)

    check = checkRow(i18n:Translate("DISPLAY_TIMESTAMPS"))
    check:SetValue(speak.prefs:Get("timestamps_enabled"))
    check.OnChange = function(self, value)
        speak.prefs:SetBoolean("timestamps_enabled", value)
    end

    check = checkRow(i18n:Translate("HOUR"))
    check:SetValue(not speak.prefs:Get("timestamps_type"))
    check.OnChange = function(self, value)
        speak.prefs:SetBoolean("timestamps_type", not value)
    end

    padding(messageDisplay)
    --[[ End: Display Options ]]

    --[[ Begin: Emoji Style ]]
    heading(i18n:Translate("EMOJI_STYLE"))

    padding(messageDisplay)

    group = {
        emojiRow(i18n:Translate("APPLE"), "apple"),
        emojiRow(i18n:Translate("GOOGLE"), "google"),
        emojiRow(i18n:Translate("TWITTER"), "twitter"),
        emojiRow(i18n:Translate("FACEBOOK"), "facebook")
    }

    for i=1,#group do
        group[i].OnChange = function(self, value)
            if value then
                speak.prefs:SetNumber("emoji_pack", i)
            end
        end

        group[i]:SetGroup(group)
    end

    group[speak.prefs:Get("emoji_pack")]:SetActive(true)
    --[[ End: Emoji Style ]]

    padding(messageDisplay)

    check = checkRow(i18n:Translate("EMOJI_ENABLED"))
    check:SetValue(speak.prefs:Get("emoji_enabled"))
    check.OnChange = function(self, value)
        speak.prefs:SetBoolean("emoji_enabled", value)
    end

    padding(messageDisplay)

    root:AddSheet(i18n:Translate("MESSAGE_DISPLAY"), messageDisplay, "icon16/comments.png", false, false, i18n:Translate("MESSAGE_DISPLAY_POPOVER"))

    messageDisplay = vgui.Create("DScrollPanel", root)

    padding(messageDisplay)
    heading(i18n:Translate("SOUNDS"))
    padding(messageDisplay)

    split = vgui.Create( "DIconLayout", messageDisplay)
    split:Dock(TOP)
    split:SetSpaceX(root:GetPadding())

    left = vgui.Create("DPanel", split)
    left:SetPaintBackground(false)
    left:SetSize(self:GetWide() / 2 - root:GetPadding() * 2 - 1, left:GetTall() * 6)

    local rightSounds = vgui.Create("DPanel", split)
    rightSounds:SetPaintBackground(false)
    rightSounds:SetSize(self:GetWide() / 2 - root:GetPadding() * 2 - 1, rightSounds:GetTall() * 6)

    group = {
        radioRow("Ding", left),
        radioRow("Ta-da", left),
        radioRow("Here you go", left),
        radioRow("Knock Brush", left),
        radioRow("Boing", left),
        radioRow("Plink", left),
        radioRow("Hi", rightSounds),
        radioRow("Woah!", rightSounds),
        radioRow("Drop", rightSounds),
        radioRow("Wow", rightSounds),
        radioRow("Yoink", rightSounds),
        radioRow("None", rightSounds)
    }

    for i=1,#group do
        group[i]:SetGroup(group)

        group[i].OnChange = function(self, value)
            if value then
                speak.prefs:SetNumber("notification_sound", i)
                if speak.notificationSounds[i] then
                    surface.PlaySound("speak/" .. speak.notificationSounds[i] .. ".mp3")
                end
            end
        end
    end

    group[math.Clamp(speak.prefs:Get("notification_sound"), 1, 12)]:SetActive(true)

    padding(messageDisplay)

    heading("Duration")
    padding(messageDisplay)

    local row = vgui.Create("DPanel", messageDisplay)
    row:SetPaintBackground(false)
    row:Dock(TOP)

    local button = vgui.Create( "DNumSlider", row)
    button:Dock(FILL)
    button:DockPadding(8, 0, 8, 0)
    button:SetMin(0)
    button:SetMax(30)
    button:SetDecimals(0)
    button:SetConVar("speak_notification_duration")
    button.Label:SetVisible(false)

    padding(messageDisplay)

    heading(i18n:Translate("DO_NOT_DISTURB"))
    padding(messageDisplay)

    check = checkRow("Disable notifications")
    check:SetValue(not speak.prefs:Get("notification_enabled"))
    check.OnChange = function(self, value)
        speak.prefs:SetBoolean("notification_enabled", not value)
    end

    root:AddSheet(i18n:Translate("NOTIFICATIONS"), messageDisplay, "icon16/bell.png", false, false, i18n:Translate("NOTIFICATIONS_POPOVER"))

    local settings = vgui.Create("DProperties", panel)

    local timestampsColor = settings:CreateRow(i18n:Translate("TIMESTAMPS"), i18n:Translate("COLOR"))
    timestampsColor:Setup("VectorColor", {})
    local def = speak.prefs:Get("timestamps_color")
    timestampsColor:SetValue(Vector(def.r / 255, def.g / 255, def.b / 255))
    function timestampsColor:DataChanged(value)
        local new = string.Split(value, " ")
        speak.prefs:SetTable("timestamps_color", Color(math.Round(tonumber(new[1], 10) * 255), math.Round(tonumber(new[2], 10) * 255), math.Round(tonumber(new[3], 10) * 255)))
    end

    local fontName = settings:CreateRow(i18n:Translate("FONT"), i18n:Translate("NAME"))
    fontName:Setup("Generic")
    fontName:SetValue(speak.prefs:Get("font_name"))
    function fontName:DataChanged(value)
        speak.prefs:SetString("font_name", value)
    end

    local fontSize = settings:CreateRow(i18n:Translate("FONT"), i18n:Translate("SIZE"))
    fontSize:Setup("Int", {min = 8, max = 36})
    fontSize:SetValue(speak.prefs:Get("font_size"))
    function fontSize:DataChanged(value)
        speak.prefs:SetNumber("font_size", value)
    end

    local fontWeight = settings:CreateRow(i18n:Translate("FONT"), i18n:Translate("WEIGHT"))
    fontWeight:Setup("Combo", {text = speak.prefs:Get("font_weight")})
    fontWeight:AddChoice("100", 100)
    fontWeight:AddChoice("200", 200)
    fontWeight:AddChoice("300", 300)
    fontWeight:AddChoice("400", 400)
    fontWeight:AddChoice("500", 500)
    fontWeight:AddChoice("600", 600)
    fontWeight:AddChoice("700", 700)
    fontWeight:AddChoice("800", 800)
    fontWeight:AddChoice("900", 900)
    function fontWeight:DataChanged(value)
        speak.prefs:SetNumber("font_weight", value)
    end

    local function BorderTypeToString()
        local type = speak.prefs:Get("font_border_type")
        if type then return i18n:Translate("DROP_SHADOW") else return i18n:Translate("STROKE") end
    end

    local fontBorder = settings:CreateRow(i18n:Translate("BORDER"), i18n:Translate("TYPE"))
    fontBorder:Setup("Combo", {text = BorderTypeToString()})
    fontBorder:AddChoice(i18n:Translate("STROKE"), 0)
    fontBorder:AddChoice(i18n:Translate("DROP_SHADOW"), 1)
    function fontBorder:DataChanged(value)
        speak.prefs:SetBoolean("font_border_type", tobool(value))
    end


    local fontBlur = settings:CreateRow(i18n:Translate("BORDER"), i18n:Translate("BLUR"))
    fontBlur:Setup("Float", {min = 0, max = 10})
    fontBlur:SetValue(speak.prefs:Get("font_border_blur"))
    function fontBlur:DataChanged(value)
        speak.prefs:SetNumber("font_border_blur", value)
    end

    local fontOpacity = settings:CreateRow(i18n:Translate("BORDER"), i18n:Translate("OPACITY"))
    fontOpacity:Setup("Float", {min = 0, max = 1})
    fontOpacity:SetValue(speak.prefs:Get("font_border_opacity"))
    function fontOpacity:DataChanged(value)
        speak.prefs:SetNumber("font_border_opacity", value)
    end

    root:AddSheet(i18n:Translate("STYLE"), settings, "icon16/palette.png", false, false, i18n:Translate("STYLE_POPOVER"))

    self:SetVisible(false)
end

function PANEL:OnClose()
    self:SetAlpha(0)
end

function PANEL:OnRemove()
    self:SetAlpha(0)
end

vgui.Register("speak.Settings", PANEL, "DFrame")
