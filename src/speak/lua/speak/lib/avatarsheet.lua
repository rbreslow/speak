local AvatarSheet = {}
AvatarSheet.prototype = {}
AvatarSheet.__index = AvatarSheet.prototype

setmetatable(AvatarSheet, {
  --- Constructs a new AvatarSheet.
  -- @return AvatarSheet instance
  __call = function(self)
    local instance = setmetatable({
      avatars = {},
      players = {},
      data = "",
      expired = false
    }, self)

    hook.Add("HUDPaint", tostring(instance), function()
      if instance.expired then
        instance:_Render()
        instance.expired = false
      end
    end)

    return instance
  end
})

--[[ PRIVATE: ]]

function AvatarSheet.prototype:_Render()
  -- Switch our rendering context to render avatar sheet
  render.PushRenderTarget(GetRenderTarget("avatarsheet", 1024, 512))
  render.Clear(255, 255, 255, 255, true, true)

  cam.Start2D()
  -- Paint every avatar only one frame to our rendering context
  for i = 1, #self.avatars do self.avatars[i]:PaintManual() end
  cam.End2D()

  -- Get the base64 binary data for the spritesheet
  local data = render.Capture({
    format = "png",
    h = ScrH(),
    w = ScrW(),
    x = 0,
    y = 0
  })

  self.data = string.gsub(util.Base64Encode(data), "\n", "")

  if self.cb then self.cb(self.data) end

  -- Return to our previous rendering context
  render.PopRenderTarget()

  -- Destroy the used avatar instances
  for i = 1, #self.avatars do self.avatars[i]:Remove() end
end

--[[ PUBLIC: ]]

--- Update the avatar sheet.
-- @param cb Callback to return base64 PNG image data to
function AvatarSheet.prototype:Update(cb)
  IS.enforce_arg(1, "Update", "function", type(cb))

  self.players = {}
  self.avatars = {}

  local x = 0
  local y = 0

  for _, player in pairs(player.GetAll()) do
    if x == 16 then
      x = 0
      y = y + 1
    end

    local avatar = vgui.Create("AvatarImage")
    avatar:SetPaintedManually(true)
    avatar:SetSize(64, 64)
    avatar:SetPos(64 * x, 64 * y)
    avatar:SetPlayer(player, 64)

    self.players[player:UserID()] = {x = x, y = y}

    table.insert(self.avatars, avatar)

    x = x + 1
  end

  self.cb = cb
  self.expired = true
end

--- Get a player's x/y coordinates in the sheet.
-- @param player The player
function AvatarSheet.prototype:PlayerToPos(player)
  IS.enforce_arg(1, "PlayerToPos", "Player", type(player))

  return self.players[player:UserID()].x, self.players[player:UserID()].y
end

return AvatarSheet
