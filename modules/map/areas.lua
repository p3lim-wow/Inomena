-- this should be added to C_Map.GetMapInfoAtPosition
local additionalAreas = {
	[36] = { -- Burning Steppes
		{
			mapID = 33, -- Blackrock Mountain
			rect = CreateRectangle(0.1768, 0.2335, 0.3005, 0.3643),
		},
	},
	[32] = { -- Searing Gorge
		{
			mapID = 33, -- Blackrock Mountain
			rect = CreateRectangle(0.3383, 0.4390, 0.7688, 0.8900),
			needsLabel = true,
		},
	},
	[71] = { -- Tanaris
		{
			mapID = 75, -- Caverns of Time
			rect = CreateRectangle(0.6104, 0.6983, 0.4429, 0.5407),
		},
	},
	[127] = { -- Crystalsong Forest
		{
			mapID = 125, -- Dalaran
			rect = CreateRectangle(0.2165, 0.3113, 0.2899, 0.4131),
			needsLabel = true,
		},
	},
	[97] = { -- Azuremyst Isle
		{
			mapID = 103, -- The Exodar
			rect = CreateRectangle(0.1230, 0.3426, 0.2027, 0.4663),
		},
	},
	[2151] = { -- The Forbidden Reach
		{
			mapID = 2102, -- The War Creche
			rect = CreateRectangle(0.4429, 0.5576, 0.5710, 0.7898),
			needsLabel = true,
		},
		{
			mapID = 2154, -- Froststone Vault
			rect = CreateRectangle(0.5698, 0.6480, 0.2841, 0.3947),
			needsLabel = true,
		},
		{
			mapID = 2101, -- The Support Creche
			rect = CreateRectangle(0.3453, 0.3833, 0.2857, 0.3452),
			needsLabel = true,
		},
		{
			mapID = 2100, -- The Siege Creche
			rect = CreateRectangle(0.7282, 0.7611, 0.4910, 0.5605),
			needsLabel = true,
		},
	},
}

WorldMapFrame:AddCanvasClickHandler(function(self, button, cursorX, cursorY) -- BIG TAINT
	if button == 'LeftButton' then
		local zones = additionalAreas[self:GetMapID() or 0]
		if zones then
			for _, zone in next, zones do
				if zone.rect:EnclosesPoint(cursorX, cursorY) then
					self:SetMapID(zone.mapID) -- TAINT
					return true
				end
			end
		end
	end

	return false
end)

-- add labels to missing zones that don't already have them
local function postUpdateLabel(self)
	local map = self.dataProvider:GetMap()
	if map:IsCanvasMouseFocus() then
		local zones = additionalAreas[map:GetMapID() or 0]
		if zones then
			local cursorX, cursorY = map:GetNormalizedCursorPosition()
			for _, zone in next, zones do
				if zone.needsLabel and zone.rect:EnclosesPoint(cursorX, cursorY) then
					local mapInfo = C_Map.GetMapInfo(zone.mapID)
					self:SetLabel(_G.MAP_AREA_LABEL_TYPE.AREA_NAME, mapInfo.name, '')
					self:EvaluateLabels()
					break
				end
			end
		end
	end
end

for provider in next, WorldMapFrame.dataProviders do
	if provider.OnAdded == AreaLabelDataProviderMixin.OnAdded then
		provider.Label:HookScript('OnUpdate', postUpdateLabel)
	end
end
