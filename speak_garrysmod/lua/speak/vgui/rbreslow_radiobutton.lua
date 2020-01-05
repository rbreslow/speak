local PANEL = {}

local old = SKIN.GwenTexture
SKIN.GwenTexture        = Material("gwenskin/GModDefault.png")
local RadioButton_Checked		= GWEN.CreateTextureNormal( 448, 64, 15, 15, Material( "gwenskin/GModDefault.png" ) )
local RadioButton				= GWEN.CreateTextureNormal( 464, 64, 15, 15, Material( "gwenskin/GModDefault.png" ) )
local RadioButtonD_Checked		= GWEN.CreateTextureNormal( 448, 80, 15, 15, Material( "gwenskin/GModDefault.png" ) )
local RadioButtonD				= GWEN.CreateTextureNormal( 464, 80, 15, 15, Material( "gwenskin/GModDefault.png" ) )
SKIN.GwenTexture = old

AccessorFunc(PANEL, "_active", "Active", FORCE_BOOL)
AccessorFunc(PANEL, "_group", "Group", nil)

function PANEL:Init()
    self._active = false
    self._group = nil

    self:SetSize(15, 15)
    self:SetText("")
end

function PANEL:DoClick()
    self._active = true

    self:OnChange(true)

    for i=1,#self._group do
        if self._group[i] ~= self then
            self._group[i]:SetActive(false)
            self._group[i]:OnChange(false)
        end
    end
end

function PANEL:Paint(w, h)
    if self._active then

        if self:GetDisabled() then
            RadioButtonD_Checked( 0, 0, w, h )
        else
            RadioButton_Checked( 0, 0, w, h )
        end

    else
        if self:GetDisabled() then
            RadioButtonD( 0, 0, w, h )
        else
            RadioButton( 0, 0, w, h )
        end

    end
end

vgui.Register("rbreslow_RadioButton", PANEL, "DButton")