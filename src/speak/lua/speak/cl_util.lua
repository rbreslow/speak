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
