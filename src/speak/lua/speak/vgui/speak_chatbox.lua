local PANEL = {}

local base64 = include "speak/vendor/base64.lua"
local emojiData = include "speak/gen/emoji_data.lua"

local blur = Material("pp/blurscreen")
local scrw = ScrW()
local scrh = ScrH()

local startTime = 0
local lifeTime = .25
local startVal = 0
local endVal = 0
local value = startVal

local startedOpenAnim = false
local startedCloseAnim = true

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
    speak.menu:Toggle()
  end)

  self.html:AddFunction("speak", "ChatInitialized", function()
    hook.Run("speak.ChatInitialized")
  end)

  self.html:AddFunction("speak", "OpenUrl", function(str)
    gui.OpenURL(str)
  end)

  self.html:AddFunction("speak", "Close", function()
    chat.Close()
  end)

  self.html:AddFunction("speak", "MaxLengthHit", function()
    surface.PlaySound("Resource/warning.wav")
  end)

  self.html:AddFunction("speak", "GetAutocompleteData", function()
    -- fill in emoji/emoticon autocompletion array
    local data = {}

    for _,emote in pairs(speak.emoticons.list) do
      table.insert(data, {label = emote.code, value = emote.url})
      -- emotes override emoji
      table.RemoveByValue(emojiData, emote.code)
    end

    for _,emojiName in pairs(emojiData) do
      table.insert(data, {label = emojiName, value = ""})
    end

    for _,player in pairs(player.GetAll()) do
      table.insert(data, {label = string.format("@%s", player:Nick()), value = ChatAvatar(player)})
    end

    return data
  end)

  self:Refresh()

  self:SetVisible(true)
  self:MakePopup()

  self:SetKeyboardInputEnabled(false)
  self:SetMouseInputEnabled(false)
end

function PANEL:OnScreenSizeChanged(_, _)
  scrw = ScrW()
  scrh = ScrH()
end

function PANEL:Paint(w, h)
  if self:IsOpen() and not startedOpenAnim then
    startedCloseAnim = false
    startedOpenAnim = true
    startVal = 0
    endVal = 140
    startTime = CurTime()
  elseif not self:IsOpen() and not startedCloseAnim then
    startedOpenAnim = false
    startedCloseAnim = true

    startVal = 140
    endVal = 0
    startTime = CurTime()
  end

  local fraction = (CurTime() - startTime) / lifeTime
  fraction = math.Clamp(fraction, 0, 1)

  value = Lerp(fraction, startVal, endVal)

  if value > 0 then
    surface.SetMaterial(blur)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    blur:SetFloat("$blur", 1.25)
    blur:Recompute()

    render.UpdateScreenEffectTexture()

    local x, y = self:ScreenToLocal(0, 0)

    surface.DrawTexturedRect(x, y, scrw, scrh)

    surface.SetDrawColor(Color(0, 0, 0, value))
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

function PANEL:Refresh()
  local bundle = include "speak/gen/bundle.lua"
  self.html:SetHTML(base64:dec(bundle))
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
