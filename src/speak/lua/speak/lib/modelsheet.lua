local ModelSheet = {}
ModelSheet.prototype = {}
ModelSheet.__index = ModelSheet.prototype

setmetatable(ModelSheet, {
  --- Constructs a new ModelSheet.
  -- @return ModelSheet instance
  __call = function(self)
    local instance = setmetatable({
      models = {},
      players = {},
      data = '',
      expired = false
    }, self)

    return instance
  end
})

--- To be called within a 2D rendering hook.
function ModelSheet.prototype:Render()
  if not self.expired then return end

  render.PushRenderTarget(GetRenderTarget("modelSheet", 1024, 512))
  
  render.SetWriteDepthToDestAlpha(false)
  render.Clear(0, 0, 0, 0, true, true)

  cam.Start2D()
  -- Paint every model only one frame to our rendering context
  for i=1, #self.models do
    self.models[i]:PaintManual()
  end
  cam.End2D()
  
  -- Get the base64 binary data for the spritesheet
  local data = render.Capture({
    format = "png",
    h = ScrH(),
    w = ScrW(),
    x = 0,
    y = 0,
    alpha = true
  })
  
  self.data = string.gsub(util.Base64Encode(data), "\n", "")
  
  if self.cb then
    self.cb(self.data)
  end
  
  render.PopRenderTarget()
  
  -- Destroy the used model instances
  for i=1,#self.models do
    self.models[i]:Remove()
  end

  self.expired = false
end

--- Update the model sheet.
-- @param cb Callback to return base64 PNG image data to
function ModelSheet.prototype:Update(cb)
  IS.enforce_arg(1, 'Update', 'function', type(cb))
    
    self.players = {}
    self.models = {}
    
    local x = 0
    local y = 0

    for _, player in pairs(player.GetAll()) do
      if x == 16 then
        x = 0
        y = y + 1
      end
      
      local panel = vgui.Create("DModelPanel")
      panel:SetSize(64, 64)
      panel:SetPos(64 * x, 64 * y)
      panel:SetModel("models/buildables/teleporter.mdl")
      panel:SetAmbientLight(Color(102, 102, 102, 102))
      panel:SetPaintedManually(true)
      
      local model = player:GetModel()
      if model ~= nil then
        panel.Entity:SetModel(model)
        local bone = panel.Entity:LookupBone("ValveBiped.Bip01_Head1")

        if bone ~= nil then
          local headPos = panel.Entity:GetBonePosition(bone)

          -- these numbers were found through guessing and testing, they look good
          panel:SetFOV(10)
          panel:SetCamPos(headPos - Vector(-54, 0, -12))
          panel:SetLookAt(headPos)

          panel.Entity:SetEyeTarget(headPos - Vector( -15, 0, 0 ) )

          panel.LayoutEntity = function(_, _) return end

          table.insert(self.models, panel)
        else
          panel:Remove()

          local avatar = vgui.Create("AvatarImage")
          avatar:SetPaintedManually(true)
          avatar:SetSize(64, 64)
          avatar:SetPos(64 * x, 64 * y)
          avatar:SetPlayer(player, 64)

          table.insert(self.models, avatar)
        end
      end
      
      self.players[player:UserID()] = {x = x, y = y}
      
      x = x + 1
    end
    
    self.cb = cb
    self.expired = true
  end
  
  --- Get a player's x/y coordinates in the sheet.
  -- @param player The player
  function ModelSheet.prototype:PlayerToPos(player)
    IS.enforce_arg(1, 'PlayerToPos', 'Player', type(player))
    
    return self.players[player:UserID()].x, self.players[player:UserID()].y
  end

return ModelSheet
