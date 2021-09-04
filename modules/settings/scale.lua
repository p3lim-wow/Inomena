local _, addon = ...

function addon:PLAYER_LOGIN()
	local _, height = GetPhysicalScreenSize()
	if (768 / height) < (768 / 1200) then
		-- game can't be scaled further than 0.64, so instead we'll lock the UI scale and
		-- rescale everything else ourselves
		C_CVar.SetCVar('useuiscale', '1')
		C_CVar.SetCVar('uiscale', '1')

		-- we'll need to use an integer instead of a float to avoid pixel smearing
		UIParent:SetScale(math.ceil((768 / height) * 100 + 0.5) / 100)
	else
		-- within the boundaries, just set the scale cvar
		C_CVar.SetCVar('useuiscale', '0')
	end

	return true
end
