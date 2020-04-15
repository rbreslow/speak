include "speak/static/bundle.lua"

local PANEL = {}

AccessorFunc(PANEL, "open", "Open", FORCE_BOOL)

local blur = Material("pp/blurscreen")
local scrw = ScrW()
local scrh = ScrH()

function PANEL:Refresh()
  speak.logger.info "Refreshing HTML View"
  self:Close()
  self.html:SetHTML(speak.bundle)
end

function PANEL:Init()
  self.anim = {}
  self.anim.startTime = 0
  self.anim.lifeTime = .25
  self.anim.startVal = 0
  self.anim.endVal = 0
  self.anim.fadingIn = false
  self.anim.fadingOut = true

  self.open = false

  self:SetSizable(true)
  self:SetScreenLock(true)
  self:SetDeleteOnClose(false)
  self:SetTitle("")

  self:ShowCloseButton(false)

  self:DockPadding(6, 6, 6, 6)

  self:SetPaintedManually(true)
  self:KillFocus()

  self.html = vgui.Create("DHTML", self)
  self.html:SetAllowLua(true)
  self.html:Dock(FILL)

  self.html:AddFunction("speak", "say", function(str)
    RunConsoleCommand("say", str)
  end)

  self.html:AddFunction("speak", "sayTeam", function(str)
    RunConsoleCommand("say_team", str)
  end)

  self.html:AddFunction("chat", "close", chat.Close)

  self.html:AddFunction("hook", "run", function(name, ...)
    return hook.Run(name, ...)
  end)

  self.html:AddFunction("surface", "playSound", function(soundFile)
    return surface.PlaySound(soundFile)
  end)

  self.html:AddFunction("speak", "OpenSettings", function()
    speak.menu:Toggle()
  end)

  self.html:AddFunction("speak", "OpenUrl", function(str)
    gui.OpenURL(str)
  end)

  self.html:AddFunction("speak", "GetAutocompleteData", function()
    local data = {}

    for _,emote in pairs(speak.emoji.list) do
      table.insert(data, {label = emote.code, value = emote.url})
    end

    for _,player in pairs(player.GetAll()) do
      table.insert(data, {label = string.format("@%s", player:Nick()), value = ChatAvatar(player)})
    end

    return data
  end)

  self:Refresh()
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
  if self:GetOpen() and not self.anim.fadingIn then
    self.anim.fadingIn = true
    self.anim.fadingOut = false
    
    self.anim.startVal = 0
    self.anim.endVal = 150
    self.anim.startTime = CurTime()
  elseif not self:GetOpen() and not self.anim.fadingOut then
    self.anim.fadingIn = false
    self.anim.fadingOut = true

    self.anim.startVal = 150
    self.anim.endVal = 0
    self.anim.startTime = CurTime()
  end

  local fraction = (CurTime() - self.anim.startTime) / self.anim.lifeTime
  fraction = math.Clamp(fraction, 0, 1)

  local alpha = Lerp(fraction, self.anim.startVal, self.anim.endVal)

  if alpha > 0 then
    speak.util.BlurredRect(self, 4, 0.2, alpha)

    surface.SetDrawColor(Color(5, 5, 5, alpha))
    surface.DrawRect(0, 0, w, h)

    -- surface.SetDrawColor(Color(0, 0, 0, 240))
    -- self:DrawOutlinedRect()
  end
end

function PANEL:AddText(message)
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
  self.open = false

  self.html:RunJavascript("speakJS.default.close();")

  self:SetKeyboardInputEnabled(false)
  self:SetMouseInputEnabled(false)

  self:KillFocus()
end

function PANEL:Open(isTeamChat)
  self.open = true

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
