local PANEL = {}

function PANEL:Init()
    self:SetPaintBackground(true)

    self.sections = {}
    self.sections.dnd = speak.vgui.MenuSection(speak.i18n:Translate("DO_NOT_DISTURB"), self)
    self.sections.dnd:DockMargin(0, 8, 0, 0)
    self.sections.dnd.label:DockMargin(8, 0, 8, 8)

    self.dndDesc = Label(speak.i18n:Translate("DO_NOT_DISTURB_DESC"), self.sections.dnd)
    self.dndDesc:SetWrap(true)
    self.dndDesc:SetFont("speak_Menu_Paragraph")
    self.dndDesc:SetTextColor(speak.menu:GetDarkMode() and SKIN.text_normal or SKIN.text_dark)
    self.dndDesc:Dock(TOP)
    self.dndDesc:DockMargin(8, 0, 8, 8)
      
    self.dndCheck = speak.vgui.CheckBoxLabel(speak.i18n:Translate("DISABLE_NOTIFICATIONS"), self.sections.dnd)
    self.dndCheck:SetValue(not speak.prefs:Get("notification_enabled"))
    self.dndCheck.OnChange = function(self, value)
        speak.prefs:SetBoolean("notification_enabled", not value)
    end
    self.dndCheck:SetEnabled(not speak.prefs:IsEnforced("notification_enabled"))
    self.dndCheck:DockMargin(8, 0, 8, 0)
    
    speak.vgui.HorizontalRule(self)
    
    self.sections.sounds = speak.vgui.MenuSection(speak.i18n:Translate("SOUNDS"), self)
    self.sections.sounds.label:DockMargin(8, 0, 8, 8)

    self.soundsRow = vgui.Create("speak_Row", self.sections.sounds)
    self.soundsRow:SetEnabled(not speak.prefs:IsEnforced("speak_notification_sound"))
    self.soundsRow:DockMargin(8, 0, 8, 0)

    local left = vgui.Create("Panel")
    self.soundsRow:Add(left)    
    local right = vgui.Create("Panel")
    self.soundsRow:Add(right)

    local group = {
        speak.vgui.RadioButtonLabel("Ding", left),
        speak.vgui.RadioButtonLabel("Ta-da", left),
        speak.vgui.RadioButtonLabel("Here you go", left),
        speak.vgui.RadioButtonLabel("Knock Brush", left),
        speak.vgui.RadioButtonLabel("Boing", left),
        speak.vgui.RadioButtonLabel("Plink", left),
        speak.vgui.RadioButtonLabel("Hi", right),
        speak.vgui.RadioButtonLabel("Woah!", right),
        speak.vgui.RadioButtonLabel("Drop", right),
        speak.vgui.RadioButtonLabel("Wow", right),
        speak.vgui.RadioButtonLabel("Yoink", right),
        speak.vgui.RadioButtonLabel("None", right)
    }

    for i=1,#group do
        group[i]:SetEnabled(not speak.prefs:IsEnforced("notification_sound"))

        group[i]:SetGroup(group)
        group[i].OnChange = function(self, value)
            if value then
                speak.prefs:SetNumber("notification_sound", i)
                if speak.notificationSounds[i] then
                    surface.PlaySound("speak/" .. speak.notificationSounds[i] .. ".mp3")
                end
            end
        end

        group[i]:DockMargin(0, (i == 1 or i == 7) and 0 or 4, 0, 0)
    end

    group[math.Clamp(speak.prefs:Get("notification_sound"), 1, 12)]:SetChecked(true)

    speak.vgui.HorizontalRule(self)

    self.sections.duration = speak.vgui.MenuSection(speak.i18n:Translate("DURATION"), self)
    self.sections.duration.label:DockMargin(8, 0, 8, 0)

    self.durationContainer = vgui.Create("DPanel", self.sections.duration)
    self.durationContainer:SetPaintBackground(false)
    self.durationContainer:Dock(TOP)

    self.durationContainer:SetEnabled(not speak.prefs:IsEnforced("notification_duration"))

    self.durationSlider = vgui.Create("DNumSlider", self.durationContainer)
    self.durationSlider:Dock(FILL)
    self.durationSlider:DockPadding(4, 0, 0, 0)
    self.durationSlider:SetMin(0)
    self.durationSlider:SetMax(30)
    self.durationSlider:SetDecimals(0)
    self.durationSlider:SetConVar("speak_notification_duration")
    self.durationSlider.Label:SetVisible(false)
end

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)

    self.dndDesc:SizeToContents()

    for _,cell in ipairs(self.soundsRow.cells) do
        cell:SizeToChildren(true, true)
    end

    self.soundsRow:PerformLayout()
end

PANEL.AllowAutoRefresh = true

function PANEL:PostAutoRefresh()
    self:Clear()
    self:Init()
end

derma.DefineControl("speak_Notifications", "", PANEL, "DScrollPanel")
