
local PANEL = {}

function PANEL:Init()
	self:SetSkin("Terminal")
	

end

function PANEL:PerformLayout()

end

function PANEL:Think()

end

function PANEL.Paint(self, w, h)
	derma.SkinHook("Paint", "TKMarket", self, w, h)
	return true
end

vgui.Register("tk_market", PANEL)