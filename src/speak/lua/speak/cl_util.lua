speak.util = speak.util or {}

local deg2rad = math.rad
local sin = math.sin
local cos = math.cos

local draw = draw
local surface = surface
function speak.util.RoundedRect(x, y, w, h, radius, color)
    local poly = {}
    
    for i = 0, 3 do
        local _x = x + (i < 2 and w - radius or radius)
        local _y = y + (i % 3 > 0 and h - radius or radius)
        
        local a = 90 * i
        
        for j = 0, 15 do
            local _a = deg2rad(a + j * 6)
            
            -- 16 vertices, 64 in total
            poly[i * 16 + j] = {x = _x + radius * sin(_a), y = _y - radius * cos(_a)}
        end
    end
    
    draw.NoTexture()
    surface.SetDrawColor(color)
    surface.DrawPoly(poly)
end

local blur = Material("pp/blurscreen")
local ScrW = ScrW
local ScrH = ScrH
local render = render
function speak.util.BlurredRect(panel, amount, passes, alpha)
    -- Intensity of the blur.
    amount = amount or 5
    alpha = alpha or 255

    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 0, 0, alpha)

    local x, y = panel:LocalToScreen(0, 0)

    for i = -(passes or 0.2), 1, 0.2 do
        -- Do things to the blur material to make it blurry.
        blur:SetFloat("$blur", i * amount)
        blur:Recompute()

        -- Draw the blur material over the screen.
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end
end
