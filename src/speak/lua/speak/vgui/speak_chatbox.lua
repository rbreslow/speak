local PANEL = {}

function PANEL:Init()
  self._isOpen = false

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
  self.html:SetAllowLua(true)

  self.html:AddFunction("speak", "Say", function(str)
    speak.Say(str)
  end)

  self.html:AddFunction("speak", "SayTeam", function(str)
    speak.SayTeam(str)
  end)

  self.html:AddFunction("speak", "GetPref", function(str)
    return speak.prefs:Get(str)
  end)

  self.html:AddFunction("speak", "PressTab", function(str)
    return hook.Run("OnChatTab", str)
  end)

  self.html:AddFunction("speak", "TextChanged", function(str)
    return hook.Run("ChatTextChanged", str)
  end)

  self.html:AddFunction("speak", "OpenSettings", function()
    RunConsoleCommand("speak_settings")
  end)

  self.html:AddFunction("speak", "ChatInitialized", function()
    hook.Run("speak.ChatInitialized")
  end)

  self.html:AddFunction("speak", "OpenUrl", function(str)
    gui.OpenURL(str)
  end)

  self.html:AddFunction("speak", "ClearEmojo", function()
    speak.lastEmojo = nil
  end)

  self.html:AddFunction("speak", "Close", function()
    chat.Close()
  end)

  self.html:AddFunction("speak", "MaxLengthHit", function()
    surface.PlaySound("Resource/warning.wav")
  end)

  -- Awesomium compatibility
  self.html:AddFunction("speak", "CurTime", function()
    return CurTime() * 1000
  end)

  self:Refresh()

  self:SetVisible(true)
  self:MakePopup()

  self:SetKeyboardInputEnabled(false)
  self:SetMouseInputEnabled(false)
end

-- appearance related stuff is split out into cl_theme.lua
PANEL.OnScreenSizeChanged = speak.backgroundOnScreenSizeChanged
PANEL.Paint = speak.backgroundPaint

function PANEL:AppendLine(message)
  self.html:RunJavascript(string.format(
    "speakJS.default.addText(%s);", 
    util.TableToJSON(message)
  ))
end

function PANEL:SetBooleanProperty(property, value)
  self.html:RunJavascript(
    string.format("speakJS.default.%s = %s;", property, value and "true" or "false"))
end

function PANEL:SetStringProperty(property, value)
  self.html:RunJavascript(string.format("speakJS.default.%s = '%s';", property, value))
end

function PANEL:SetRawProperty(property, value)
  self.html:RunJavascript(string.format("speakJS.default.%s = %s;", property, value))
end

-- http://lua-users.org/wiki/BaseSixtyFour
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function b64dec(data)
  data = string.gsub(data, '[^' .. b .. '=]', '')
  return (data:gsub('.', function(x)
    if (x == '=') then
      return ''
    end
    local r, f = '', (b:find(x) - 1)
    for i = 6, 1, -1 do
      r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
    end
    return r
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if (#x ~= 8) then
      return ''
    end
    local c = 0
    for i = 1, 8 do
      c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
    end
    return string.char(c)
  end))
end

function PANEL:Refresh()
  self.html:SetHTML(b64dec(speak.encodedTheme))
end

function PANEL:RequestFocus()
  self:SetKeyboardInputEnabled(true)
  self:SetMouseInputEnabled(true)

  self.html:RequestFocus()
  self.html:RunJavascript("speakJS.ChatboxState.focus();")
end

function PANEL:Close()
  self._isOpen = false

  self.html:RunJavascript("speakJS.default.close();")

  self:SetKeyboardInputEnabled(false)
  self:SetMouseInputEnabled(false)
end

function PANEL:IsOpen()
  return self._isOpen
end

function PANEL:Open(isTeamChat)
  self._isOpen = true

  self.html:RunJavascript(string.format(
    "speakJS.default.open(%s, '%s', '%s');",
    isTeamChat and "true" or "false", 
    speak.i18n:Translate("SAY"),
    speak.i18n:Translate("SAY_TEAM")
  ))

  self:RequestFocus()
end

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

vgui.Register("speak.Chatbox", PANEL, "DFrame")
