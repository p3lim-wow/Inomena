-- this should be added to C_Map.GetMapLinksForMap
local additionalMapLinks = {
	[33] = { -- Blackrock Mountain - Blackrock Spire
		{
			atlasName = 'poi-door-right',
			linkedUiMapID = 34,
			position = CreateVector2D(0.7025, 0.6342)
		},
		{
			atlasName = 'poi-door-down',
			linkedUiMapID = 35,
			position = CreateVector2D(0.4800, 0.5938)
		},
	},
	[34] = { -- Blackrock Mountain - Blackrock Caverns
		{
			atlasName = 'poi-door-left',
			linkedUiMapID = 33,
			position = CreateVector2D(0.3837, 0.8028)
		},
	},
	[35] = { -- Blackrock Mountain - Blackrock Depths
		{
			atlasName = 'poi-door-up',
			linkedUiMapID = 33,
			position = CreateVector2D(0.5948,  0.8956)
		},
	},
}

local function postRefreshAllData(self)
	local map = self:GetMap()
	local mapID = map:GetMapID()

	local mapLinks = additionalMapLinks[mapID]
	if not mapLinks then
		return
	end

	local mapGroupID = C_Map.GetMapGroupID(mapID)
	if not mapGroupID then
		return
	end

	local mapGroupMembers = C_Map.GetMapGroupMembersInfo(mapGroupID)
	if not mapGroupMembers then
		return
	end

	for _, mapLink in next, mapLinks do
		for _, mapGroupMember in next, mapGroupMembers do
			if mapGroupMember.mapID == mapLink.linkedUiMapID then
				mapLink.name = mapGroupMember.name
				map:AcquirePin('MapLinkPinTemplate', mapLink)
			end
		end
	end
end

for provider in next, WorldMapFrame.dataProviders do
	if provider.RefreshAllData == MapLinkDataProviderMixin.RefreshAllData then
		hooksecurefunc(provider, 'RefreshAllData', postRefreshAllData)
	end
end
