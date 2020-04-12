local PANEL = {}

local render = render
local RoundedRect = speak.util.RoundedRect

function PANEL:Init()
    self.colors = {}
    self.strokeSize = 1
    
    self:UpdateColors(self:GetSkin())

    self.button = vgui.Create("speak_RadioButtonLabel")
    self.button.OnChange = function(_, val)
        self:OnChange(val)
    end

    self.button:DockPadding(8, 0, 8, 0)
    
    self:Add(self.button)
end

function PANEL:GetButton()
    return self.button:GetButton()
end

function PANEL:UpdateColors(skin)
    -- hue of the radio button
    local tex = skin.GwenTexture
    local hue = ColorToHSL(GWEN.TextureColor(455, 71, tex))  

    if speak.menu:GetDarkMode() then
        self.colors.base = Color(0, 0, 0)
        local h,s,l = ColorToHSL(self.colors.base)
        self.colors.interior = HSLToColor(h, s, l + .16)
        self.colors.stroke = HSLToColor(h, s, l + .3)
        
        self.colors.interiorActive = HSLToColor(hue, .1, .2)
        self.colors.strokeActive = HSLToColor(hue, .6, .6)
    else
        self.colors.base = Color(255, 255, 255)
        local h,s,l = ColorToHSL(self.colors.base)
        self.colors.interior = HSLToColor(h, s, l - .12)
        h,s,l = ColorToHSL(self.colors.interior)
        self.colors.stroke = HSLToColor(h, s, l - .14)

        self.colors.interiorActive = HSLToColor(hue, .3, .8)
        self.colors.strokeActive = HSLToColor(hue, .3, .4)
    end
end

function PANEL:ApplySchemeSettings()
    self.BaseClass.ApplySchemeSettings(self)
    self:UpdateColors(self:GetSkin())
end

function PANEL:SetText(text)
    self.button:SetText(text)
end

function PANEL:SetContent(panel)
    panel:SetCursor("hand")
    panel.OnMousePressed = function(_, keyCode)
        self.button:OnMousePressed(keyCode)
    end

    self:Add(panel)
end

function PANEL:OnChange(_)
end

function PANEL:SetChecked(active)
    self.button:SetChecked(active)
end

function PANEL:SetGroup(group)
    self.button:SetGroup(group)
end

function PANEL:SetEnabled(enabled)
    self.BaseClass.SetEnabled(self, enabled)
    
    self.button:SetEnabled(enabled)
end

function PANEL:Paint(w, h)
    -- Reset everything to known good
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()
    
    -- Enable stencils
    render.SetStencilEnable(true)
    -- Set everything up everything draws to the stencil buffer instead of the screen
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    
    -- Mask
    RoundedRect(self.strokeSize, self.strokeSize, w - self.strokeSize * 2, h - self.strokeSize * 2, 4, self.colors.base)
    
    -- Only draw things that are in the stencil buffer
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)
    
    -- Inside
    surface.SetDrawColor(not self.button:GetChecked() and self.colors.interior or self.colors.interiorActive)
    surface.DrawRect(0, 0, w / 2, h)
    
    render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
    
    -- Outline
    RoundedRect(0, 0, w, h, 4, not self.button:GetChecked() and self.colors.stroke or self.colors.strokeActive)
    
    render.SetStencilEnable(false)
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_RadioRow", "", PANEL, "speak_Row")
