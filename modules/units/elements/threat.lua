local _, addon = ...

local THREAT_COLOR = addon:CreateColor(255, 0, 0)

function addon.unitShared.PostUpdateThreat(element, _, status)
	-- role-based simple threat glow
	local groupRole = UnitGroupRolesAssigned('player')
	if groupRole == 'TANK' then
		if status and status < 3 then
			element:SetBackdropBorderColor(THREAT_COLOR:GetRGB())
		else
			element:Hide()
		end
	elseif groupRole ~= 'NONE' then -- never use threat colors outside of dungeons
		if status and status >= 1 then
			element:SetBackdropBorderColor(THREAT_COLOR:GetRGB())
		else
			element:Hide()
		end
	else
		element:Hide()
	end
end
