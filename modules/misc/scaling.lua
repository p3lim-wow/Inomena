local E, F, C = unpack(select(2, ...))

function E:PLAYER_LOGIN()
	local resolution = select(GetCurrentResolution(), GetScreenResolutions())
	local resolutionHeight = string.match(resolution, '%d+x(%d+)')

	if((768 / resolutionHeight) < (768 / 1200)) then
		-- Game can't scale further than 0.64
		-- Instead we change the UI scale to 1 and the UIParent scale to the correct one
		SetCVar('useuiscale', 1)
		SetCVar('uiscale', 1)
		UIParent:SetScale(768 / resolutionHeight)
	end
end

