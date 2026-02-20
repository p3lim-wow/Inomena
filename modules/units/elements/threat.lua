local _, addon = ...

function addon.unitShared.PostUpdateThreat(element, _, status)
	-- role-based simple threat glow
	local groupRole = UnitGroupRolesAssigned('player')
	if groupRole == 'TANK' then
		if status and status < 3 then
			element:SetBackdropBorderColor(addon.colors.threat:GetRGB())
		else
			element:Hide()
		end
	elseif groupRole ~= 'NONE' then -- never use threat colors outside of dungeons
		if status and status >= 1 then
			element:SetBackdropBorderColor(addon.colors.threat:GetRGB())
		else
			element:Hide()
		end
	else
		element:Hide()
	end
end
