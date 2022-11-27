local addonName, addon = ...

-- make the minimap square
local MASK = [[Interface\BUTTONS\WHITE8X8]]
Minimap:SetMaskTexture(MASK)

-- also deal with hybrid minimap
addon:HookAddOn('Blizzard_HybridMinimap', function()
	HybridMinimap.CircleMask:SetTexture(MASK, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	-- HybridMinimap.MapCanvas:SetMaskTexture(HybridMinimap.CircleMask)
end)

-- add custom border texture made by lightspark to replace the compass
local border = Minimap:CreateTexture(addonName .. 'MinimapBorder', 'BORDER', nil, 3)
border:SetPoint('CENTER', 0, 0)
border:SetTexture(([[Interface\AddOns\%s\assets\minimap]]):format(addonName))
border:SetTexCoord(434 / 1024, 866 / 1024, 1 / 512, 433 / 512)
border:SetSize(216, 216)

-- remove blob outlines
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- expose shape for LDBIcon-1.0
function GetMinimapShape()
	return 'SQUARE'
end

-- disable expansion landing button animations
ExpansionLandingPageMinimapButton:UnregisterEvent('PLAYER_ENTERING_WORLD')

-- move and scale the expansion landing button depending on "garrison" type
hooksecurefunc(ExpansionLandingPageMinimapButton, 'UpdateIcon', function(self)
	self:ClearAllPoints()

	local garrisonType = C_Garrison.GetLandingPageGarrisonType()
	if garrisonType == Enum.GarrisonType.Type_6_0 then
		addon:Print('garrison', 'draenor')
		self:SetPoint('BOTTOMLEFT', Minimap)
	elseif garrisonType == Enum.GarrisonType.Type_7_0 then
		self:SetPoint('BOTTOMLEFT', Minimap, 3, 3)
		self:SetSize(38, 38)
	elseif garrisonType == Enum.GarrisonType.Type_8_0 then
		addon:Print('garrison', 'bfa')
		self:SetPoint('BOTTOMLEFT', Minimap)
	elseif garrisonType == Enum.GarrisonType.Type_9_0 then
		local covenantID = C_Covenants.GetActiveCovenantID()
		if covenantID == Enum.CovenantType.Kyrian then
			self:SetPoint('BOTTOMLEFT', Minimap, -2, 3)
			self:SetSize(42, 42)
		elseif covenantID == Enum.CovenantType.Venthyr then
			self:SetPoint('BOTTOMLEFT', Minimap, -1, 2)
			self:SetSize(42, 42)
		elseif covenantID == Enum.CovenantType.NightFae then
			self:SetPoint('BOTTOMLEFT', Minimap, 1, 1)
			self:SetSize(38, 38)
		elseif covenantID == Enum.CovenantType.Necrolord then
			self:SetPoint('BOTTOMLEFT', Minimap, -1, 3)
			self:SetSize(42, 42)
		end
	end
end)
