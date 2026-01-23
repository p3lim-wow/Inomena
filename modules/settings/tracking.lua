local _, addon = ...

-- automatically track a specific set of objects on the minimap

-- we have to track by textures, they are unique enough (hopefully)
local TRACKING_TEXTURES = {
	[136456] = true, -- Flight Master
	[136458] = true, -- Innkeeper
	[524052] = true, -- Target
	[524051] = true, -- Focus Target
	[535616] = true, -- Track Quest POIs
	[136466] = addon.PLAYER_CLASS == 'HUNTER', -- Stable Master
}

-- there are some things we want to not automatically handle tracking for
local IGNORED_TRACKING_TEXTURES = {
	[237607] = true, -- Low-Level Quests
	[4675649] = true, -- Warband Completed Quests
}

function addon:OnLogin()
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local info = C_Minimap.GetTrackingInfo(index)
		if not IGNORED_TRACKING_TEXTURES[info.texture] then
			C_Minimap.SetTracking(index, TRACKING_TEXTURES[info.texture] or false)
		end
	end
end
