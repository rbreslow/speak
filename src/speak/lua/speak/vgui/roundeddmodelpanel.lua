local PANEL = {}

AccessorFunc(PANEL, "m_iRadius", "Radius", FORCE_NUMBER)

local render = render
local RoundedRect = speak.util.RoundedRect

function PANEL:Init()
    self.color = Color(255, 255, 255)
    self.m_iRadius = 8
end

function PANEL:Paint(w, h)
    -- Reset everything to known good
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()
    
    -- Enable stencils
    render.SetStencilEnable(true)
    -- Set everything up everything draws to the stencil buffer instead of the screen
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    
    -- Mask
    RoundedRect(0, 0, w, h, self.m_iRadius, self.color)
    
    -- Only draw things that are in the stencil buffer
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)

    -- Inside
    self.BaseClass.Paint(self, w, h)

    render.SetStencilEnable(false)
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_RoundedDModelPanel", "", PANEL, "DModelPanel")
