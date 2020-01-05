ModelSheet = {}
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

        hook.Add('RenderScene', tostring(instance), function()
            if instance.expired then
                instance:_Render()
                instance.expired = false
            end
        end)

        return instance
    end
})

--[[ PRIVATE: ]]

function ModelSheet.prototype:_Render()
    local rt = GetRenderTargetEx("modelSheet",
        1024,
        512,
        RT_SIZE_NO_CHANGE,
        MATERIAL_RT_DEPTH_SHARED,
        0x0010,
        CREATERENDERTARGETFLAGS_HDR,
        IMAGE_FORMAT_RGB888
    );

    render.PushRenderTarget(rt, 0, 0, 1024, 512);

    render.Clear(0, 0, 0, 0, true, true);

    -- Paint every model only one frame to our rendering context
    for i=1, #self.models do
        self.models[i]:PaintManual()
    end

    -- Get the base64 binary data for the spritesheet
    local data = render.Capture({
        format = "png",
        quality = 100,
        h = ScrH(),
        w = ScrW(),
        x = 0,
        y = 0
    })

    self.data = string.gsub(util.Base64Encode(data), "\n", "")

    if self.cb then
        self.cb(self.data)
    end

    render.PopRenderTarget(rt);

    -- Destroy the used model instances
    for i=1,#self.models do
        self.models[i]:Remove()
    end
end

--[[ PUBLIC: ]]

--- Update the model sheet.
-- @param cb Callback to return base64 PNG image data to
function ModelSheet.prototype:Update(cb)
    IS.enforce_arg(1, 'Update', 'function', type(cb))

    self.players = {}
    self.models = {}

    local x = 0
    local y = 0

    -- Prep and instantiate a sheet of models for rendering in HUDPaint
    for _, player in pairs(player.GetAll()) do
        if x == 16 then
            x = 0
            y = y + 1
        end

        local panel = vgui.Create("DModelPanel")
        panel:SetSize(64, 64)
        panel:SetPos(64 * x, 64 * y)
        panel:SetModel("models/buildables/teleporter.mdl")
        panel:SetPaintedManually(true)

        if player:GetModel() ~= nil then
            panel.Entity:SetModel(player:GetModel())

            local iSeq = panel.Entity:LookupSequence("walk_all")
            if iSeq <= 0 then iSeq = panel.Entity:LookupSequence("WalkUnarmed_all") end
            if iSeq <= 0 then iSeq = panel.Entity:LookupSequence("walk_all_moderate") end
            if iSeq > 0 then panel.Entity:ResetSequence(iSeq) end

            panel:SetFOV(10)

            panel:SetCamPos(Vector(0, 60, panel.Entity:OBBCenter( ).z));

            local angle_front = Angle(0, 90, 0);

            panel.__LayoutEntity = panel.__LayoutEntity or panel.LayoutEntity;

            function panel:LayoutEntity(ent)
                self.__LayoutEntity(self, ent);

                ent:SetAngles(angle_front);
                ent:SetPos(Vector(0, 0, -32))

                panel:SetLookAt(panel.Entity:OBBCenter());
            end
        end

        self.players[player:UserID()] = {x = x, y = y}

        table.insert(self.models, panel)

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