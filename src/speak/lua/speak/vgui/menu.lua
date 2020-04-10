surface.CreateFont("speak_Menu_Heading", {
    font = "Trebuchet MS",
    size = 18,
})

surface.CreateFont("speak_Menu_Paragraph", {
    font = "Tahoma",
    size = 14
})

speak.menu = {}
speak.menu.open = false
speak.menu.darkMode = false

AccessorFunc(speak.menu, "open", "Open", FORCE_BOOL)
AccessorFunc(speak.menu, "width", "Width", FORCE_BOOL)
AccessorFunc(speak.menu, "height", "Height", FORCE_BOOL)
AccessorFunc(speak.menu, "darkMode", "DarkMode", FORCE_BOOL)

local PANEL = {}

function PANEL:Init()
    local skin = self:GetSkin()
    local tex = skin.GwenTexture
    -- get the HSL of the DPanel background texture
    local _,_,l = ColorToHSL(GWEN.TextureColor((128 / 2), 256 + (128 / 2), tex))
    speak.menu.darkMode = l < .5

    self:SetSizable(true)
    self:SetDeleteOnClose(false)
    self:SetTitle(speak.i18n:Translate("PREFERENCES"))

    self.scrh = ScrH()
    self:InvalidateLayout(true)

    self.tabs = vgui.Create("DPropertySheet", self)
    self.tabs:Dock(FILL)

    self.tabs:AddSheet(speak.i18n:Translate("MESSAGE_DISPLAY"), vgui.Create("speak_Messages", self.tabs), "icon16/comments.png", false, false, speak.i18n:Translate("MESSAGE_DISPLAY_POPOVER"))
    self.tabs:AddSheet(speak.i18n:Translate("THEMES"), vgui.Create("speak_Themes", self.tabs), "icon16/palette.png", false, false, speak.i18n:Translate("THEMES_POPOVER"))
    self.tabs:AddSheet(speak.i18n:Translate("NOTIFICATIONS"), vgui.Create("speak_Notifications", self.tabs), "icon16/bell.png", false, false, speak.i18n:Translate("NOTIFICATIONS_POPOVER"))
end

function PANEL:OnScreenSizeChanged(_, h)
    self.scrh = h
    self:InvalidateLayout()
end

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)
    
    self:SetSize(384, self.scrh - self.scrh / 2)
    self:CenterVertical()
    self:CenterHorizontal()
end

function PANEL:MakePopup()
    self.BaseClass.MakePopup(self)

    -- or else the chatbox is going to consume clicks
    self:SetFocusTopLevel(true)
end

function PANEL:OnClose()
    speak.menu.open = false

    -- should always start on Messages
    self.tabs:SetActiveTab(self.tabs:GetItems()[1].Tab)

    -- return focus to chatbox input field
    if chat.IsOpen() then
        speak.view:RequestFocus()
    end
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_Menu", "", PANEL, "DFrame")

function speak.menu:Toggle()
    self.open = not self.open

    if IsValid(self.panel) then
        if self.open then
            self.panel:SetVisible(true)
            self.panel:MakePopup()
        else
            self.panel:Close()
        end
    else
        self.panel = vgui.Create("speak_Menu")
        self.panel:MakePopup()
    end
end

function speak.menu:Rebuild()
    if IsValid(self.panel) then
        if self.open then
            self.panel:Close()
        else
            self.panel:Remove()
        end
    end  
end

hook.Add("SpeakLanguageChanged", "speak_Menu_Rebuild", function() speak.menu:Rebuild() end)
hook.Add("preferences.policyupdate", "speak_Menu_Rebuild", function() speak.menu:Rebuild() end)  

PANEL = {}

function PANEL:Init()
    self:SetPaintBackground(false)
    self:Dock(TOP)

    self.label = vgui.Create("DLabel", self)
    self.label:SetFont("speak_Menu_Heading")
    self.label:Dock(TOP)
end

function PANEL:ApplySchemeSettings()
    self.BaseClass.ApplySchemeSettings(self)
  
    local skin = self:GetSkin()
    self.label:SetTextColor(speak.menu:GetDarkMode() and skin.text_normal or skin.text_dark)
  end
  
function PANEL:SetText(text)
    self.label:SetText(text)
    self.label:SizeToContents()
end

function PANEL:PerformLayout()
    self:SizeToChildren(true, true)
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_MenuSection", "", PANEL, "DPanel")

function speak.vgui.MenuSection(text, parent)
    local section = vgui.Create("speak_MenuSection", parent)
    section:SetText(text)

    return section
end

PANEL = {}

function PANEL:Init()
    self:Dock(TOP)
    self:DockMargin(8, 16, 8, 16)

    if speak.menu:GetDarkMode() then
        self.color = HSLToColor(0, 0, .3)
    else
        self.color = HSLToColor(0, 0, .8)
    end
end

function PANEL:Paint(w, _)
    surface.SetDrawColor(self.color)
    surface.DrawLine(0, 0, w, 0)
end

function PANEL:GetContentSize()
    return self:GetWide(), 1
end
  
function PANEL:SizeToContents()
    self:SetSize(self:GetContentSize())
end

function PANEL:PerformLayout()
    self:SizeToContents()
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_HorizontalRule", "", PANEL, "DPanel")

function speak.vgui.HorizontalRule(parent)
    return vgui.Create("speak_HorizontalRule", parent)
end
