local PANEL = {}

function PANEL:Init()
    self.isOpen = false
    self.isTeamChat = false

    self:SetTitle("")
    self:SetDeleteOnClose(false)
    self:SetScreenLock(true)
    self:ShowCloseButton(false)
    self:SetSizable(true)
    self:SetPaintedManually(true)

    self:DockMargin(0, 0, 0, 0)
    self:DockPadding(6, 6, 6, 6)

    self.html = vgui.Create("DHTML", self)
    self.html:Dock(FILL)
    self.html:SetAllowLua(false)

    self.html:AddFunction( "speak", "Say", function(str)
        speak.Say(str)
    end)
    self.html:AddFunction( "speak", "SayTeam", function(str)
        speak.SayTeam(str)
    end)
    self.html:AddFunction( "speak", "GetPref", function(str)
        return speak.prefs:Get(str)
    end)

    self.html:AddFunction( "speak", "PressTab", function(str)
        return hook.Run("OnChatTab", str)
    end)
    self.html:AddFunction( "speak", "TextChanged", function(str)
        return hook.Run("ChatTextChanged", str)
    end)
    self.html:AddFunction( "speak", "OpenSettings", function(str)
        RunConsoleCommand("speak_settings")
    end)
    self.html:AddFunction( "speak", "ChatInitialized", function(str)
        hook.Run("speak.ChatInitialized")
    end)
    self.html:AddFunction( "speak", "OpenUrl", function(str)
        gui.OpenURL(str)
    end)
    self.html:AddFunction("speak", "ClearEmojo", function()
        speak.lastemojo = nil
    end)
    self.html:AddFunction("speak", "Close", function()
        chat.Close()
    end)

    self.html:SetHTML(b64dec(SPEAK_THEME))

    self:SetVisible(true)
    self:MakePopup()

    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

function PANEL:Open(isTeamChat)
    self.isOpen = true
    self.isTeamChat = isTeamChat

    self.html:RunJavascript(string.format("ChatboxInstance.open(%s, '%s', '%s');", isTeamChat and "true" or "false", speak.i18n:Translate("SAY"), speak.i18n:Translate("SAY_TEAM")))

    self:ShitFocus()
end

function PANEL:ShitFocus()
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(true)

    self.html:RequestFocus()
    self.html:RunJavascript("ChatboxInstance.inputFieldElement.focus();")
end

function PANEL:IsOpen()
    return self.isOpen
end

function PANEL:Close()
    self.isOpen = false

    self.html:RunJavascript("ChatboxInstance.close();")

    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

function PANEL:AppendLine(message)
    self.html:RunJavascript(string.format("ChatboxInstance.appendLine(%s);", util.TableToJSON(message)))
end
function PANEL:SetBooleanProperty(property, value)
    self.html:RunJavascript(string.format("ChatboxInstance.%s = %s;", property, value and "true" or "false"))
end
function PANEL:SetStringProperty(property, value)
    self.html:RunJavascript(string.format("ChatboxInstance.%s = '%s';", property, value))
end
function PANEL:SetRawProperty(property, value)
    self.html:RunJavascript(string.format("ChatboxInstance.%s = %s;", property, value))
end

PANEL.Paint = SPEAK_THEME_PAINT

function PANEL:OnMouseReleased()
    local x, y = self:GetPos()
    speak.prefs:SetNumber("chatbox_x", x)
    speak.prefs:SetNumber("chatbox_y", y)

    local w, h = self:GetSize()
    speak.prefs:SetNumber("chatbox_w", w)
    speak.prefs:SetNumber("chatbox_h", h)

    self.Dragging = nil
    self.Sizing = nil
    self:MouseCapture(false)
end

vgui.Register("speak.ChatBox", PANEL, "DFrame")