surface.CreateFont("speak_Messages_ChatExample", {
    font = "Trebuchet MS",
    size = 18
})

local PANEL = {}

function PANEL:Init()
    self:SetPaintBackground(true)

    local i18n = speak.i18n

    self.sections = {}
    self.sections.avatarStyle = speak.vgui.MenuSection(i18n:Translate("AVATAR_STYLE"), self)
    self.sections.avatarStyle:DockMargin(0, 8, 0, 0)
    self.sections.avatarStyle.label:DockMargin(8, 0, 8, 8)

    local function ContainerForAvatarExample()
        local container = vgui.Create("Panel")

        local label = vgui.Create("DLabel", container)
        label:Dock(LEFT)
        label:SetText("garry")
        label:SetTextColor(Color(255, 255, 100, 255))
        label:SetExpensiveShadow(1, SKIN.text_dark)
        label:SetFont("speak_Messages_ChatExample")
        label:SizeToContents()

        return container
    end

    local avatarRow = vgui.Create("speak_RadioRow", self.sections.avatarStyle)
    avatarRow:SetText(i18n:Translate("STEAM_AVATAR"))
    avatarRow:DockMargin(8, 0, 8, 4)

    local avatarContainer = ContainerForAvatarExample()
    local avatarCenteringContainer = vgui.Create("Panel", avatarContainer)

    local avatar = vgui.Create("speak_RoundedAvatarImage", avatarCenteringContainer)
    avatar:SetSize(40, 40)
    avatar:SetSteamID("76561197960279927", 64)

    avatarCenteringContainer:SetSize(48, 48)
    avatarCenteringContainer.PerformLayout = function(self)
      avatar:SetPos(0, self:GetTall() / 2 - avatar:GetTall() / 2)
    end

    avatarCenteringContainer:Dock(LEFT)
    avatarCenteringContainer:SetZPos(-1)
    avatarCenteringContainer:DockMargin(16, 0, 0, 0)

    avatarContainer:SizeToChildren(false, true)

    avatarRow:SetContent(avatarContainer)

    local modelRow = vgui.Create("speak_RadioRow", self.sections.avatarStyle)
    modelRow:SetText(i18n:Translate("PLAYER_MODEL"))
    modelRow:DockMargin(8, 4, 8, 12)

    local modelContainer = ContainerForAvatarExample()
    local modelCenteringContainer = vgui.Create("Panel", modelContainer)

    local model = vgui.Create("speak_RoundedDModelPanel", modelCenteringContainer)
    model:SetSize(40, 40)
    model:SetModel("models/buildables/teleporter.mdl")
    model.Entity:SetModel("models/Humans/Group01/male_07.mdl")
    local bone = model.Entity:LookupBone("ValveBiped.Bip01_Head1")
    local headPos = model.Entity:GetBonePosition(bone)

    -- these numbers were found through guessing and testing, they look good
    model:SetFOV(10)
    model:SetCamPos(headPos - Vector(-54, 0, -12))
    model:SetLookAt(headPos)
    model.Entity:SetEyeTarget(headPos - Vector( -15, 0, 0 ) )

    model.LayoutEntity = function(_, _) return end

    modelCenteringContainer:SetSize(48, 48)
    modelCenteringContainer.PerformLayout = function(self)
      model:SetPos(0, self:GetTall() / 2 - model:GetTall() / 2)
    end

    modelCenteringContainer:Dock(LEFT)
    modelCenteringContainer:SetZPos(-1)
    modelCenteringContainer:DockMargin(16, 0, 0, 0)
    modelContainer:SizeToChildren(false, true)

    modelRow:SetContent(modelContainer)

    local group = {
        avatarRow:GetButton(),
        modelRow:GetButton()
    }

    for i=1,#group do
        group[i]:SetGroup(group)
        group[i]:SetEnabled(not speak.prefs:IsEnforced("avatars_type"))
    end
 
    group[speak.prefs:Get("avatars_type") and 2 or 1]:SetChecked(true)

    group[1].OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("avatars_type", false)
        end
    end

    group[2].OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("avatars_type", true)
        end
    end

    self.avatarsCheck = speak.vgui.CheckBoxLabel(i18n:Translate("AVATARS_ENABLED"), self.sections.avatarStyle)
    self.avatarsCheck:SetValue(speak.prefs:Get("avatars_enabled"))
    self.avatarsCheck.OnChange = function(self, value)
        speak.prefs:SetBoolean("avatars_enabled", value)
    end
    self.avatarsCheck:SetEnabled(not speak.prefs:IsEnforced("avatars_enabled"))
    self.avatarsCheck:DockMargin(8, 0, 8, 0)
    
    speak.vgui.HorizontalRule(self)

    self.sections.tags = speak.vgui.MenuSection(i18n:Translate("TAG_POSITION"), self)
    self.sections.tags.label:DockMargin(8, 0, 8, 8)

    local leftTags = vgui.Create("speak_RadioRow", self.sections.tags)
    leftTags:SetText(i18n:Translate("LEFT"))
    leftTags:SetChecked(speak.prefs:Get("tag_position"))
    leftTags:SetEnabled(not speak.prefs:IsEnforced("tag_position"))
    leftTags.OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("tag_position", true)
        end
    end
    leftTags:DockMargin(8, 4, 8, 4)

    local rightTags = vgui.Create("speak_RadioRow", self.sections.tags)
    rightTags:SetText(i18n:Translate("RIGHT"))
    rightTags:SetChecked(not speak.prefs:Get("tag_position"))
    rightTags:SetEnabled(not speak.prefs:IsEnforced("tag_position"))
    rightTags.OnChange = function(self, value)
        if value then
            speak.prefs:SetBoolean("tag_position", false)
        end
    end
    rightTags:DockMargin(8, 4, 8, 16)

    group = {leftTags.button.button, rightTags.button.button}

    for i=1,#group do
        group[i]:SetGroup(group)
    end

    local function ExampleTags(firstText, firstColor, secondText, secondColor)
        local container = vgui.Create("Panel")

        local tag1 = vgui.Create("DLabel", container)
        tag1:Dock(LEFT)
        tag1:DockMargin(16, 0, 0, 0)
        tag1:SetFont("speak_Messages_ChatExample")
        tag1:SetText(firstText)
        tag1:SetTextColor(firstColor)
        tag1:SetExpensiveShadow(1, SKIN.text_dark)
        tag1:SizeToContents()
        
        local tag2 = vgui.Create("DLabel", container)
        tag2:Dock(LEFT)
        tag2:SetFont("speak_Messages_ChatExample")
        tag2:SetText(secondText)
        tag2:SetTextColor(secondColor)
        tag2:SetExpensiveShadow(1, SKIN.text_dark)
        tag2:SizeToContents()

        return container
    end

    leftTags:SetContent(ExampleTags(string.format("(%s)", i18n:Translate("ADMIN")), Color(255, 100, 100, 255), " garry", Color(255, 255, 100, 255)))
    rightTags:SetContent(ExampleTags("garry ", Color(255, 255, 100, 255), string.format("(%s)", i18n:Translate("ADMIN")), Color(255, 100, 100, 255)))

    hook.Run("SpeakSettingsTagStyle", self, self.sections.tags)

    speak.vgui.HorizontalRule(self)

    self.sections.displayOptions = speak.vgui.MenuSection(i18n:Translate("DISPLAY_OPTIONS"), self)
    self.sections.displayOptions.label:DockMargin(8, 0, 8, 8)

    self.timestampsEnabledCheck = speak.vgui.CheckBoxLabel(i18n:Translate("DISPLAY_TIMESTAMPS"), self.sections.displayOptions)
    self.timestampsEnabledCheck:SetValue(speak.prefs:Get("timestamps_enabled"))
    self.timestampsEnabledCheck.OnChange = function(self, value)
        speak.prefs:SetBoolean("timestamps_enabled", value)
    end
    self.timestampsEnabledCheck:SetEnabled(not speak.prefs:IsEnforced("timestamps_enabled"))
    self.timestampsEnabledCheck:DockMargin(8, 0, 8, 8)

    self.timestampsTypeCheck = speak.vgui.CheckBoxLabel(i18n:Translate("HOUR"), self.sections.displayOptions)
    self.timestampsTypeCheck:SetValue(not speak.prefs:Get("timestamps_type"))
    self.timestampsTypeCheck.OnChange = function(self, value)
        speak.prefs:SetBoolean("timestamps_type", not value)
    end
    self.timestampsTypeCheck:SetEnabled(not speak.prefs:IsEnforced("timestamps_type"))
    self.timestampsTypeCheck:DockMargin(8, 0, 8, 0)

    speak.vgui.HorizontalRule(self)

    self.sections.emoji = speak.vgui.MenuSection(i18n:Translate("EMOJI_STYLE"), self)
    self.sections.emoji.label:DockMargin(8, 0, 8, 8)

    group = {
        speak.vgui.EmojiRow(i18n:Translate("APPLE"), "apple", self.sections.emoji):GetButton(),
        speak.vgui.EmojiRow(i18n:Translate("GOOGLE"), "google", self.sections.emoji):GetButton(),
        speak.vgui.EmojiRow(i18n:Translate("TWITTER"), "twitter", self.sections.emoji):GetButton(),
        speak.vgui.EmojiRow(i18n:Translate("FACEBOOK"), "facebook", self.sections.emoji):GetButton()
    }

    for i=1,#group do
        local element = group[i]
        local emojiRow = group[i]:GetParent():GetParent():GetParent()

        emojiRow:SetEnabled(not speak.prefs:IsEnforced("emoji_pack"))

        element:SetGroup(group)
        element.OnChange = function(self, value)
            if value then
                speak.prefs:SetNumber("emoji_pack", i)
            end 
        end
    end

    group[speak.prefs:Get("emoji_pack")]:SetChecked(true)

    self.emojiCheck = speak.vgui.CheckBoxLabel(i18n:Translate("EMOJI_ENABLED"), self.sections.emoji)
    self.emojiCheck:SetValue(speak.prefs:Get("emoji_enabled"))
    self.emojiCheck.OnChange = function(this, value)
        for _,child in ipairs(self.sections.emoji:GetChildren()) do
            if child ~= this then
                child:SetEnabled(value)
            end
        end

        speak.prefs:SetBoolean("emoji_enabled", value)
    end
    self.emojiCheck:SetEnabled(not speak.prefs:IsEnforced("emoji_enabled"))
    self.emojiCheck:OnChange(self.emojiCheck:GetChecked())
    self.emojiCheck:DockMargin(8, 8, 8, 8)

    -- allow the DockMargin above to work
    local hr = speak.vgui.HorizontalRule(self.sections.emoji)
    hr:DockMargin(8, 8, 0, 0)
    hr.Paint = nil
end

PANEL.AllowAutoRefresh = true

function PANEL:PostAutoRefresh()
    self:Clear()
    self:Init()
end

derma.DefineControl("speak_Messages", "", PANEL, "DScrollPanel")

PANEL = {}

function PANEL:Init()
    self.button = vgui.Create("speak_RadioButtonLabel", self)

    self:Add(self.button)

    self.container = vgui.Create("DPanel")
    self.container:SetPaintBackground(false)
    self.container:SetCursor("hand")

    self.container.OnMousePressed = function(_, keyCode)
        self.button:OnMousePressed(keyCode)
    end

    self.emoji = vgui.Create("DHTML", self.container)
    -- TODO: calculate this the right way
    self.emoji:SetWide(108)
    self.emoji:Dock(LEFT)
    self.emoji:DockMargin(8, 0, 0, 0)
    self.emoji:SetMouseInputEnabled(false)

    self.emoji.OnDocumentReady = function(self, _)
        self.SetEnabled = function(self, enabled)
            self:RunJavascript(string.format("document.body.style.opacity = \"%s\";", enabled and "1" or ".3"))
        end
    end

    self:Add(self.container)

    self:DockMargin(8, 0, 8, 0)
end

function PANEL:SetEnabled(enabled)
    self.BaseClass.SetEnabled(self, enabled)

    self.button:SetEnabled(enabled)
    self.container:SetEnabled(enabled)
    self.emoji:SetEnabled(enabled)
end

function PANEL:SetText(text)
    self.button:SetText(text)
end

function PANEL:SetShort(short)
    local initialOpacity = self:IsEnabled() and "1" or ".3"

    self.emoji:SetHTML([[
        <style>html, body { overflow: hidden; margin: 0; padding: 0; opacity: ]] .. initialOpacity .. [[;-webkit-user-select: none; user-select:none; cursor: default; } img { margin: 0; padding: 0; width: 21px; }</style>

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
end

function PANEL:GetButton()
    return self.button:GetButton()
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_EmojiRow", "", PANEL, "speak_Row")

function speak.vgui.EmojiRow(text, short, parent)
    local panel = vgui.Create("speak_EmojiRow", parent)
    panel:SetText(text)
    panel:SetShort(short)
    return panel
end
