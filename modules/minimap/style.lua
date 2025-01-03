local _, addon = ...

-- adjust size and add border
Minimap:SetSize(200, 200)
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

-- disable expansion landing button animations
addon:Hide('ExpansionLandingPageMinimapButton', 'LoopingGlow')
addon:Hide('ExpansionLandingPageMinimapButton', 'SideToastGlow')
addon:Hide('ExpansionLandingPageMinimapButton', 'CircleGlow')
addon:Hide('ExpansionLandingPageMinimapButton', 'SoftButtonGlow')
addon:Hide('ExpansionLandingPageMinimapButton', 'AlertBG')
addon:Hide('ExpansionLandingPageMinimapButton', 'AlertText')

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
		if garrisonType == Enum.GarrisonType.Type_6_0_Garrison then
			self:SetPoint('BOTTOMLEFT', Minimap)
			self:SetSize(36, 36)
		elseif garrisonType == Enum.GarrisonType.Type_7_0_Garrison then
			self:SetPoint('BOTTOMLEFT', Minimap, 3, 3)
			self:SetSize(38, 38)
		elseif garrisonType == Enum.GarrisonType.Type_8_0_Garrison then
			addon:Print('garrison', 'bfa')
			self:SetPoint('BOTTOMLEFT', Minimap)
		elseif garrisonType == Enum.GarrisonType.Type_9_0_Garrison then
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

-- move queue status back to the minimap
function addon:PLAYER_LOGIN()
	-- have to delay this because something else is just forcing it back
	QueueStatusButton:SetParent(Minimap)
	QueueStatusButton:ClearAllPoints()
	QueueStatusButton:SetPoint('TOPRIGHT', Minimap, -5, -6)
	QueueStatusButton:SetSize(28, 28)
	QueueStatusButton:SetFrameStrata('HIGH')

	-- something keeps moving it
	QueueStatusButton.SetParent = nop
	QueueStatusButton.ClearAllPoints = nop
	QueueStatusButton.SetPoint = nop
	QueueStatusButton.SetSize = nop
	QueueStatusButton.SetFrameStrata = nop
end

-- disable eye animations by hiding all components
addon:Hide('QueueStatusButton', 'Eye', 'texture')
addon:Hide('QueueStatusButton', 'Eye', 'EyeInitial')
addon:Hide('QueueStatusButton', 'Eye', 'EyeSearchingLoop')
addon:Hide('QueueStatusButton', 'Eye', 'EyeMouseOver')
addon:Hide('QueueStatusButton', 'Eye', 'EyeFoundInitial')
addon:Hide('QueueStatusButton', 'Eye', 'EyeFoundLoop')
addon:Hide('QueueStatusButton', 'Eye', 'GlowBackLoop')
addon:Hide('QueueStatusButton', 'Eye', 'EyePokeInitial')
addon:Hide('QueueStatusButton', 'Eye', 'EyePokeEnd')

-- create our own static eye texture that is not tied to animation
local eye = QueueStatusButton:CreateTexture(nil, 'ARTWORK')
eye:SetAllPoints()
eye:SetAtlas('groupfinder-eye-single')

-- reanchor tracking so we can use the menu ourselves
MinimapCluster.Tracking:SetParent(Minimap)
MinimapCluster.Tracking:ClearAllPoints()
MinimapCluster.Tracking.Button:SetMenuAnchor(AnchorUtil.CreateAnchor('TOPRIGHT', Minimap, 'BOTTOMLEFT'))

-- easy calendar access
Minimap:SetScript('OnMouseUp', function(self, button)
	if button == 'MiddleButton' then
		if InCombatLockdown() then
			addon:Print('Can\'t open calendar in combat')
		else
			if not C_AddOns.IsAddOnLoaded('Blizzard_Calendar') then
				C_AddOns.LoadAddOn('Blizzard_Calendar')
			end

			if CalendarFrame:IsShown() then
				HideUIPanel(CalendarFrame)
			else
				ShowUIPanel(CalendarFrame)
			end
		end
	elseif button == 'RightButton' then
		MinimapCluster.Tracking.Button:OpenMenu()
	else
		MinimapMixin.OnClick(self) -- super
	end
end)

-- disable addon buttons
function addon:OnLogin()
	local LDBI = LibStub and LibStub('LibDBIcon-1.0', true)
	if LDBI then
		for _, buttonName in next, LDBI:GetButtonList() do
			addon:Hide('LibDBIcon10_' .. buttonName)
		end

		LDBI.RegisterCallback(self, 'LibDBIcon_IconCreated', function(_, _, buttonName)
			addon:Hide('LibDBIcon10_' .. buttonName)
		end)
	end
end

-- expose shape for other addons
function GetMinimapShape() -- luacheck: ignore
	return 'SQUARE'
end
