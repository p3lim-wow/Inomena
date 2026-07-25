local _, addon = ...

function addon.unitShared.GetThreatColor(role, threatStatus)
	if not threatStatus then
		return
	end

	if role == Enum.LFGRole.Tank then
		if threatStatus == 0 then
			return addon.colors.threat.high
		elseif threatStatus == 1 or threatStatus == 2 then
			return addon.colors.threat.medium
		end
	else
		if threatStatus == 1 then
			return addon.colors.threat.low
		elseif threatStatus > 1 then
			return addon.colors.threat.high
		end
	end
end

function addon.unitShared.PostUpdateThreat(element, _, threatStatus)
	local groupRole = UnitGroupRolesAssignedEnum('player')
	if groupRole >= 0 then -- no role = -1, missing enum value
		local color = addon.unitShared.GetThreatColor(groupRole, threatStatus)
		if color then
			element:SetBackdropBorderColor(color:GetRGB())
		else
			element:Hide()
		end
	else
		element:Hide()
	end
end
