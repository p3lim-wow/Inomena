local _, addon = ...

local INVENTORY_ALERT_STATUS_SLOTS = _G.INVENTORY_ALERT_STATUS_SLOTS -- FrameXML/DurabilityFrame.lua

-- color the border based on equipment durability
local DURABILITY_COLORS = { -- alternative to INVENTORY_ALERT_COLORS
	CreateColor(1, 0.82, 0.18),
	CreateColor(0.93, 0.07, 0.07),
}

function addon:UPDATE_INVENTORY_DURABILITY()
	local alert = 0 -- has at least 6 durability left
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if status > alert then
			alert = status
		end
	end

	local color = DURABILITY_COLORS[alert]
	if color then
		Minimap:SetBorderColor(color:GetRGB())
	else
		Minimap:SetBorderColor(0, 0, 0)
	end
end
