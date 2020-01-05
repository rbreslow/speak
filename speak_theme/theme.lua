local blur = Material("pp/blurscreen")
local scrw = ScrW()
local scrh = ScrH()

SPEAK_THEME_PAINT = function(panel, w, h)
    if panel.isOpen then
        surface.SetMaterial(blur)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        blur:SetFloat("$blur", 1.25)
        blur:Recompute()

        render.UpdateScreenEffectTexture()

        local x, y = panel:ScreenToLocal(0, 0)

        surface.DrawTexturedRect(x, y, scrw, scrh)

        surface.SetDrawColor(Color(0, 0, 0, 140))
        surface.DrawRect(0, 0, w, h)
    end
end