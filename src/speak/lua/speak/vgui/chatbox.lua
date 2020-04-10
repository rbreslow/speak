include "speak/static/bundle.lua"

local PANEL = {}

local blur = Material("pp/blurscreen")
local scrw = ScrW()
local scrh = ScrH()

function PANEL:Refresh()
  speak.logger.info "Refreshing HTML View"
  self:Close()
  self.html:SetHTML(speak.bundle)
end

function PANEL:Init()
  self.isOpen = false

  self.anim = {}
  self.anim.startTime = 0
  self.anim.lifeTime = .25
  self.anim.startVal = 0
  self.anim.endVal = 0
  self.anim.value = self.anim.startVal
  self.anim.startedOpen = false
  self.anim.startedClose = true

  self:SetSizable(true)
  self:SetScreenLock(true)
  self:SetDeleteOnClose(false)
  self:SetTitle("")

  self:ShowCloseButton(false)

  self:DockMargin(0, 0, 0, 0)
  self:DockPadding(6, 6, 6, 6)

  self:SetPaintedManually(true)
  self:KillFocus()

  self.html = vgui.Create("DHTML", self)
  self.html:SetAllowLua(true)

  self:Refresh()
  
  self.html:Dock(FILL)

  self.html:AddFunction("speak", "Say", function(str)
    RunConsoleCommand("say", str)
  end)

  self.html:AddFunction("speak", "SayTeam", function(str)
    RunConsoleCommand("say_team", str)
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
    speak.menu:Toggle()
  end)

  self.html:AddFunction("speak", "ChatInitialized", function()
    hook.Run("speak.ChatInitialized")
  end)

  self.html:AddFunction("speak", "OpenUrl", function(str)
    gui.OpenURL(str)
  end)

  self.html:AddFunction("speak", "Close", chat.Close)

  self.html:AddFunction("speak", "MaxLengthHit", function()
    surface.PlaySound("Resource/warning.wav")
  end)

  self.html:AddFunction("speak", "GetAutocompleteData", function()
    -- fill in emoji/emoticon autocompletion array
    local data = {}

    for _,emote in pairs(speak.emoticons.list) do
      table.insert(data, {label = emote.code, value = emote.url})
      -- -- emotes override emoji
      -- table.RemoveByValue(self.emojiData, emote.code)
    end

    for _,player in pairs(player.GetAll()) do
      table.insert(data, {label = string.format("@%s", player:Nick()), value = ChatAvatar(player)})
    end

    return data
  end)
end

function PANEL:Clear()
  if IsValid(self.html) then
      self.html:Remove()
  end
end

function PANEL:OnScreenSizeChanged(_, _)
  scrw = ScrW()
  scrh = ScrH()
end

function PANEL:Paint(w, h)
  if self:IsOpen() and not self.anim.startedOpen then
    self.anim.startedOpen = true
    self.anim.startedClose = false
    
    self.anim.startVal = 0
    self.anim.endVal = 140
    self.anim.startTime = CurTime()
  elseif not self:IsOpen() and not self.anim.startedClose then
    self.anim.startedOpen = false
    self.anim.startedClose = true

    self.anim.startVal = 140
    self.anim.endVal = 0
    self.anim.startTime = CurTime()
  end

  local fraction = (CurTime() - self.anim.startTime) / self.anim.lifeTime
  fraction = math.Clamp(fraction, 0, 1)

  self.anim.value = Lerp(fraction, self.anim.startVal, self.anim.endVal)

  if self.anim.value > 0 then
    surface.SetMaterial(blur)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    blur:SetFloat("$blur", 1.25)
    blur:Recompute()

    render.UpdateScreenEffectTexture()

    local x, y = self:ScreenToLocal(0, 0)

    surface.DrawTexturedRect(x, y, scrw, scrh)

    surface.SetDrawColor(Color(0, 0, 0, self.anim.value))
    surface.DrawRect(0, 0, w, h)
  end
end

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

function PANEL:RefreshAutocomplete()
  self.html:RunJavascript("speakJS.default.refreshAutocomplete();")
end

function PANEL:MakePopup()
  self.BaseClass.MakePopup(self)

  self:SetMouseInputEnabled(true)

  self.html:RequestFocus()
  self.html:SetMouseInputEnabled(true)
  self.html:RunJavascript("speakJS.ChatboxState.focus();")
end

function PANEL:Close()
  self.isOpen = false

  self.html:RunJavascript("speakJS.default.close();")

  self:SetKeyboardInputEnabled(false)
  self:SetMouseInputEnabled(false)

  self:KillFocus()
end

function PANEL:IsOpen()
  return self.isOpen
end

function PANEL:Open(isTeamChat)
  self.isOpen = true

  self.html:RunJavascript(string.format(
    "speakJS.default.open(%s, '%s', '%s');",
    isTeamChat and "true" or "false", 
    speak.i18n:Translate("SAY"),
    speak.i18n:Translate("SAY_TEAM")
  ))

  self:MakePopup()
end

function PANEL:OnMouseReleased()
  local x, y = self:GetPos()
  speak.prefs:SetNumber("chatbox_x", x)
  speak.prefs:SetNumber("chatbox_y", y)

  local w, h = self:GetSize()
  speak.prefs:SetNumber("chatbox_w", w)
  speak.prefs:SetNumber("chatbox_h", h)

  self.BaseClass.OnMouseReleased(self)
end

PANEL.AllowAutoRefresh = true

function PANEL:PostAutoRefresh()
  self:Clear()
  self:Init()
end

derma.DefineControl("speak_Chatbox", "", PANEL, "DFrame")
