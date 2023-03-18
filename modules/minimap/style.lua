local addonName, addon = ...

-- add custom border
addon:AddBackdrop(Minimap)

-- make the minimap square
local MASK = [[Interface\BUTTONS\WHITE8X8]]
Minimap:SetMaskTexture(MASK)

-- also deal with hybrid minimap
addon:HookAddOn('Blizzard_HybridMinimap', function()
	HybridMinimap.CircleMask:SetTexture(MASK, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	-- HybridMinimap.MapCanvas:SetMaskTexture(HybridMinimap.CircleMask)
end)

-- remove blob outlines
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- expose shape for LDBIcon-1.0
function GetMinimapShape()
	return 'SQUARE'
end

-- disable expansion landing button animations
ExpansionLandingPageMinimapButton:UnregisterEvent('PLAYER_ENTERING_WORLD')

-- render it above other crap
ExpansionLandingPageMinimapButton:SetFrameStrata('HIGH')

-- easy access to weekly chest
ExpansionLandingPageMinimapButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
ExpansionLandingPageMinimapButton:SetScript('OnClick', function(self, button)
	if button == 'RightButton' then
		if WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown() then
			HideUIPanel(WeeklyRewardsFrame)
		else
			WeeklyRewards_ShowUI()
		end
	else
		self:ToggleLandingPage()
	end
end)

-- move and scale the expansion landing button depending on "garrison" type
hooksecurefunc(ExpansionLandingPageMinimapButton, 'UpdateIcon', function(self)
	self:ClearAllPoints()

	if self.garrisonMode then
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
	else
		local expansionInfo = ExpansionLandingPage:GetOverlayMinimapDisplayInfo()
		if expansionInfo then
			self:SetPoint('BOTTOMLEFT', Minimap, 2, 3)
			self:SetSize(32, 32)
		end
	end
end)
