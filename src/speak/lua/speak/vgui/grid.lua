local PANEL = {}

AccessorFunc(PANEL, "margin", "Margin")

function PANEL:Init()
    self.cells = {}
    self.margin = 0

    self:SetPaintBackground(false)

    self:Dock(TOP)
end

function PANEL:Add(cell)
    table.insert(self.cells, cell)

    cell:SetParent(self)

    cell:Dock(LEFT)

    cell.PerformLayout = function(self, _, _)
        local parent = self:GetParent()
        self:DockMargin(parent:GetMargin(), 0, parent:GetMargin(), 0)
        self:SetWide(parent:GetWide() / #parent.cells - parent:GetMargin() * 2)
    end

    self:SetTall(self:CalculateHeight())

    self:InvalidateLayout(true)
end

function PANEL:CalculateHeight()
    local height = 0

    for _,v in ipairs(self.cells) do
       height = math.max(height, v:GetTall())
    end

    return height
end

function PANEL:PerformLayout()
    for _,v in ipairs(self.cells) do
       v:InvalidateChildren(true)
    end

    self:SetTall(self:CalculateHeight())
end

PANEL.AllowAutoRefresh = true

derma.DefineControl("speak_Row", "", PANEL, "DPanel")
