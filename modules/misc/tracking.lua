local _, addon = ...

-- textures for each tracking kind should be unique
local TRACKING = {
	[136456] = true, -- Flight Master
	[136458] = true, -- Innkeeper
	[524052] = true, -- Target
	[524051] = true, -- Focus Target
	[535616] = true, -- Track Quest POIs
}

if addon.PLAYER_CLASS == 'HUNTER' then
	TRACKING[136466] = true -- Stable Master
end

function addon:OnLogin()
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local info = C_Minimap.GetTrackingInfo(index)
		C_Minimap.SetTracking(index, TRACKING[info.texture] or false)
	end
end
