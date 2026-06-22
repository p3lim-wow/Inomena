local _, addon = ...

-- show garrison(-like) buttons as tabs on the encounter journal

local EXPANSION_GARRISONS = {
	{
		garrisonType = Enum.GarrisonType.Type_9_0_Garrison,
		tooltipTitle = EXPANSION_NAME8,
		tooltipText = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
		atlas = 'shadowlands-landingbutton-%s-up',
	},
	{
		garrisonType = Enum.GarrisonType.Type_8_0_Garrison,
		tooltipTitle = EXPANSION_NAME7,
		tooltipText = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
		atlas = 'bfa-landingbutton-%s-up',
	},
	{
		garrisonType = Enum.GarrisonType.Type_7_0_Garrison,
		tooltipTitle = EXPANSION_NAME6,
		tooltipText = ORDER_HALL_LANDING_PAGE_TITLE,
		atlas = 'ClassHall-Circle-%s', -- from classhallframe, nice high res icon
	},
	{
		garrisonType = Enum.GarrisonType.Type_6_0_Garrison,
		tooltipTitle = EXPANSION_NAME5,
		tooltipText = GARRISON_LANDING_PAGE_TITLE,
		atlas = 'ShipMissionIcon-Siege%s-Map', -- from garrisonshipmapicons, fits well and has decent resolution
	},
}

local parent
local parentMixin = {}
function parentMixin:UpdateTabs()
	for _, tab in next, self.tabs do
		tab:SetEnabled(C_Garrison.HasGarrison(tab.garrisonType))

		if tab.garrisonType == Enum.GarrisonType.Type_9_0_Garrison then
			local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID())
			if not covenantData then
				-- just pick a default
				covenantData = C_Covenants.GetCovenantData(Enum.CovenantType.Kyrian)
			end

			tab.icon:SetAtlas(tab.atlas:format(covenantData.textureKit))
		elseif tab.garrisonType == Enum.GarrisonType.Type_8_0_Garrison then
			local factionToken = UnitFactionGroup('player') == 'Horde' and 'horde' or 'alliance'
			tab.icon:SetAtlas(tab.atlas:format(factionToken))
		elseif tab.garrisonType == Enum.GarrisonType.Type_7_0_Garrison then
			local _, classToken = UnitClass('player')
			tab.icon:SetAtlas(tab.atlas:format(classToken))
		elseif tab.garrisonType == Enum.GarrisonType.Type_6_0_Garrison then
			local factionToken = UnitFactionGroup('player')
			tab.icon:SetAtlas(tab.atlas:format(factionToken:sub(1, 1)))
		end
	end
end

local function onTabClick(self)
	-- force hide all windows to avoid weird overlapping
	HideUIPanel(ExpansionLandingPage)
	HideUIPanel(GarrisonLandingPage)
	HideUIPanel(GarrisonShipyardFrame)
	HideUIPanel(MajorFactionRenownFrame)
	HideUIPanel(CovenantRenownFrame)

	ShowGarrisonLandingPage(self.garrisonType)

	-- fix blizzard's own bugs with overlapping; they don't clean up properly themselves
	if self.garrisonType == Enum.GarrisonType.Type_9_0_Garrison then
		if GarrisonLandingPage.CovenantCallings and not GarrisonLandingPage.CovenantCallings:IsShown() then
			GarrisonLandingPage.CovenantCallings:Show()
		end
		if GarrisonLandingPage.SoulbindPanel and not GarrisonLandingPage.SoulbindPanel:IsShown() then
			GarrisonLandingPage.SoulbindPanel:Show()
		end
	else
		if GarrisonLandingPage.CovenantCallings and GarrisonLandingPage.CovenantCallings:IsShown() then
			GarrisonLandingPage.CovenantCallings:Hide()
		end
		if GarrisonLandingPage.SoulbindPanel and GarrisonLandingPage.SoulbindPanel:IsShown() then
			GarrisonLandingPage.SoulbindPanel:Hide()
		end
		if GarrisonLandingPage.ArdenwealdGardeningPanel and GarrisonLandingPage.ArdenwealdGardeningPanel:IsShown() then
			GarrisonLandingPage.ArdenwealdGardeningPanel:Hide()
		end
	end
end

local function onTabEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(self.tooltipTitle)
	GameTooltip:AddLine(self.tooltipText, 1, 1, 1)
	GameTooltip:Show()
end

local function createTab(index, info)
	local tab = CreateFrame('Button', nil, parent)
	tab:SetPoint('TOPLEFT', parent, 'TOPRIGHT', -14, -(35 + (59 * (index - 1))))
	tab:SetSize(63, 57)
	tab:SetScript('OnClick', onTabClick)
	tab:SetScript('OnEnter', onTabEnter)
	tab:SetScript('OnLeave', GameTooltip_Hide)

	-- why are these not atlases :/
	tab:SetNormalTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]]) -- UI-EJ-Tab-UnSelected
	tab:GetNormalTexture():SetTexCoord(0.25585938, 0.37890625, 0.90332031, 0.95898438)
	tab:SetPushedTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]]) -- UI-EJ-Tab-Selected
	tab:GetPushedTexture():SetTexCoord(0.12890625, 0.25195313, 0.90332031, 0.95898438)
	tab:SetDisabledTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]]) -- UI-EJ-Tab-UnSelected
	tab:GetDisabledTexture():SetTexCoord(0.25585938, 0.37890625, 0.90332031, 0.95898438)
	tab:SetHighlightTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]]) -- UI-EJ-Tab-Highlight
	tab:GetHighlightTexture():SetTexCoord(0.00195313, 0.12500000, 0.90332031, 0.95898438)
	tab:GetHighlightTexture():SetBlendMode('ADD')

	tab.garrisonType = info.garrisonType
	tab.tooltipTitle = info.tooltipTitle
	tab.tooltipText = info.tooltipText
	tab.atlas = info.atlas

	local icon = tab:CreateTexture(nil, 'OVERLAY')
	icon:SetPoint('RIGHT', -8, 0)
	icon:SetSize(40, 40)
	tab.icon = icon

	return tab
end

addon:RegisterCallback('EncounterJournal.TabSet', function(_, _, tabIndex)
	if tabIndex == 1 then
		if not parent then
			parent = Mixin(CreateFrame('Frame', nil, EncounterJournal), parentMixin)
			parent:SetAllPoints()
			parent.tabs = {}

			for index, info in next, EXPANSION_GARRISONS do
				table.insert(parent.tabs, createTab(index, info))
			end
		end

		parent:Show()
		parent:UpdateTabs()
	elseif parent then
		parent:Hide()
	end
end)
