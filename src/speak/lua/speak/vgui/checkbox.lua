local PANEL = {}

function PANEL:Init()
    self:SetPaintBackground(false)
    self:SetCursor("hand")

    self:SetTall(15)
    
    self:Dock(TOP)

    self.container = vgui.Create("Panel", self)
    self.container.PerformLayout = function(_)
      local parent = self.button:GetParent()
      parent:SetWide(self.button:GetWide())
      self.button:SetPos(0, parent:GetTall() / 2 - self.button:GetTall() / 2)
    end
    self.container:Dock(LEFT)

    self.button = vgui.Create("DCheckBox", self.container)
  
    self.button.OnChange = function(_, value)
        self:OnChange(value)
    end

    self.label = vgui.Create("DLabel", self)
    self.label:SetFont("speak_Menu_Paragraph")

    self.label:Dock(LEFT)
    self.label:DockMargin(8, 0, 0, 0)
end

function PANEL:ApplySchemeSettings()
    self.BaseClass.ApplySchemeSettings(self)
  
    local skin = self:GetSkin()
    self.label:SetTextColor(speak.menu:GetDarkMode() and skin.text_normal or skin.text_dark)
end

function PANEL:OnChange(_)
end

function PANEL:SetWide(wide)
    self.BaseClass.SetWide(self, wide)
  
    local leftMargin = self.label:GetDockMargin()
    local leftPadding = self:GetDockPadding()
    self.label:SetWide(self:GetWide() - leftMargin - self.container:GetWide() - leftPadding)
end  

function PANEL:SetValue(value)
    self.button:SetValue(value)
end

function PANEL:SetText(text)
    self.label:SetText(text)
    self.label:SizeToContents()
end

function PANEL:OnMousePressed(keyCode)
    if self:IsEnabled() and keyCode == MOUSE_LEFT then
        self.button:DoClick()
    end
end

function PANEL:SetEnabled(enabled)
    self.BaseClass.SetEnabled(self, enabled)

    for _,child in ipairs(self:GetChildren()) do
        child:SetEnabled(enabled)
    end
end

function PANEL:SetChecked(checked)
    self.button:SetChecked(checked)
end

function PANEL:GetChecked()
  return self.button:GetChecked()
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_CheckBoxLabel", "", PANEL, "DPanel")

function speak.vgui.CheckBoxLabel(text, parent)
    local check = vgui.Create("speak_CheckBoxLabel", parent)
    check:SetText(text)

    return check
end
