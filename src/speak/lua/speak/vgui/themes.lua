local PANEL = {}

function PANEL:Init()
    self.sections = {}
    self.sections.themeProperties = speak.vgui.MenuSection("Custom Theme", self)
    self.sections.themeProperties:Dock(FILL)
    self.sections.themeProperties:DockMargin(0, 8, 0, 0)

    self.sections.themeProperties.label:DockMargin(8, 0, 8, 8)

    self.themeProperties = vgui.Create("DProperties", self.sections.themeProperties)
    self.themeProperties:Dock(FILL)
    self.themeProperties:DockMargin(8, 0, 4, 0)

    local timestampsColor = self.themeProperties:CreateRow(speak.i18n:Translate("TIMESTAMPS"), speak.i18n:Translate("COLOR"))
    timestampsColor:Setup("VectorColor", {})
    local def = speak.prefs:Get("timestamps_color")
    timestampsColor:SetValue(Vector(def.r / 255, def.g / 255, def.b / 255))
    function timestampsColor:DataChanged(value)
        local new = string.Split(value, " ")
        speak.prefs:SetTable("timestamps_color", Color(math.Round(tonumber(new[1], 10) * 255), math.Round(tonumber(new[2], 10) * 255), math.Round(tonumber(new[3], 10) * 255)))
    end
    timestampsColor:SetEnabled(not speak.prefs:IsEnforced("timestamps_color"))

    local fontName = self.themeProperties:CreateRow(speak.i18n:Translate("FONT"), speak.i18n:Translate("NAME"))
    fontName:Setup("Generic")
    fontName:SetValue(speak.prefs:Get("font_name"))
    function fontName:DataChanged(value)
        speak.prefs:SetString("font_name", value)
    end
    fontName:SetEnabled(not speak.prefs:IsEnforced("font_name"))

    local fontSize = self.themeProperties:CreateRow(speak.i18n:Translate("FONT"), speak.i18n:Translate("SIZE"))
    fontSize:Setup("Int", {min = 8, max = 36})
    fontSize:SetValue(speak.prefs:Get("font_size"))
    function fontSize:DataChanged(value)
        speak.prefs:SetNumber("font_size", value)
    end
    fontSize:SetEnabled(not speak.prefs:IsEnforced("font_size"))

    local fontWeight = self.themeProperties:CreateRow(speak.i18n:Translate("FONT"), speak.i18n:Translate("WEIGHT"))
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
    fontWeight:SetEnabled(not speak.prefs:IsEnforced("font_weight"))

    local function BorderTypeToString()
        local type = speak.prefs:Get("font_border_type")
        if type then return speak.i18n:Translate("DROP_SHADOW") else return speak.i18n:Translate("STROKE") end
    end

    local fontBorder = self.themeProperties:CreateRow(speak.i18n:Translate("BORDER"), speak.i18n:Translate("TYPE"))
    fontBorder:Setup("Combo", {text = BorderTypeToString()})
    fontBorder:AddChoice(speak.i18n:Translate("STROKE"), 0)
    fontBorder:AddChoice(speak.i18n:Translate("DROP_SHADOW"), 1)
    function fontBorder:DataChanged(value)
        speak.prefs:SetBoolean("font_border_type", tobool(value))
    end
    fontBorder:SetEnabled(not speak.prefs:IsEnforced("font_border_type"))

    local fontBlur = self.themeProperties:CreateRow(speak.i18n:Translate("BORDER"), speak.i18n:Translate("BLUR"))
    fontBlur:Setup("Float", {min = 0, max = 10})
    fontBlur:SetValue(speak.prefs:Get("font_border_blur"))
    function fontBlur:DataChanged(value)
        speak.prefs:SetNumber("font_border_blur", value)
    end
    fontBlur:SetEnabled(not speak.prefs:IsEnforced("font_border_blur"))

    local fontOpacity = self.themeProperties:CreateRow(speak.i18n:Translate("BORDER"), speak.i18n:Translate("OPACITY"))
    fontOpacity:Setup("Float", {min = 0, max = 1})
    fontOpacity:SetValue(speak.prefs:Get("font_border_opacity"))
    function fontOpacity:DataChanged(value)
        speak.prefs:SetNumber("font_border_opacity", value)
    end
    fontOpacity:SetEnabled(not speak.prefs:IsEnforced("font_border_opacity"))

    self.themeProperties:SetTall()
end

PANEL.AllowAutoRefresh = true

function PANEL:PostAutoRefresh()
    self:Clear()
    self:Init()
end

derma.DefineControl("speak_Themes", "", PANEL, "DPanel")
