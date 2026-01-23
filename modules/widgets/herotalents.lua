local _, addon = ...

-- hero talents right-click swap

local TOOLTIP_TEXT = ('%s Switch to %%s %%s'):format(CreateAtlasMarkup('NPE_RightClick', 18, 18))

local function getInactiveHeroTalentSpecInfo()
	local configID = C_ClassTalents.GetActiveConfigID()
	if not configID then
		return
	end

	local specID = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization() or 0)
	if not specID then
		return
	end

	local specs, requiredLevel = C_ClassTalents.GetHeroTalentSpecsForClassSpec(configID, specID)
	if not specs or requiredLevel > UnitLevel('player') then
		return
	end

	local activeTreeID = C_ClassTalents.GetActiveHeroTalentSpec()
	if not activeTreeID then
		return
	end

	local inactiveTreeID
	for _, treeID in next, specs do
		if treeID ~= activeTreeID then
			inactiveTreeID = treeID
			break
		end
	end

	if not inactiveTreeID then
		return
	end

	local inactiveTreeInfo = C_Traits.GetSubTreeInfo(configID, inactiveTreeID)
	if not inactiveTreeInfo or not inactiveTreeInfo.subTreeSelectionNodeIDs then
		return
	end

	local inactiveEntryID, inactiveNodeID
	for _, nodeID in next, inactiveTreeInfo.subTreeSelectionNodeIDs do
		local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
		if nodeInfo and nodeInfo.isVisible and nodeInfo.isAvailable then
			for _, entryID in next, nodeInfo.entryIDs do
				local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
				if entryInfo and entryInfo.subTreeID == inactiveTreeID then
					inactiveEntryID = entryID
					break
				end
			end

			if inactiveEntryID then
				inactiveNodeID = nodeID
				break
			end
		end
	end

	if inactiveEntryID then
		return configID, inactiveNodeID, inactiveEntryID, inactiveTreeInfo
	end
end

local function onOverlayEnter(self)
	local configID, _, _, treeInfo = getInactiveHeroTalentSpecInfo()
	if configID then
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')

		local atlas = CreateAtlasMarkup(treeInfo.iconElementID, 16, 16)
		local color = C_ClassColor.GetClassColor(addon.PLAYER_CLASS)
		GameTooltip:SetText(TOOLTIP_TEXT:format(atlas, color:WrapTextInColorCode(treeInfo.name)))
		GameTooltip:Show()
	end
end

local function onOverlayClick(self)
	local configID, nodeID, entryID = getInactiveHeroTalentSpecInfo()
	if configID then
		C_Traits.SetSelection(configID, nodeID, entryID)
		onOverlayEnter(self) -- update tooltip
	end
end

-- we create this button early because SetPassThroughButtons is protected, then we re-parent it
-- once the talents UI is loaded
local overlay = addon:CreateFrame('Button')
overlay:RegisterForClicks('RightButtonUp')
overlay:SetPassThroughButtons('LeftButton') -- don't override normal click functionality
overlay:SetPropagateMouseMotion(true) -- so we own the tooltip
overlay:SetScript('OnClick', onOverlayClick)
overlay:SetScript('OnEnter', onOverlayEnter)
overlay:SetScript('OnLeave', GameTooltip_Hide)

addon:HookAddOn('Blizzard_PlayerSpells', function()
	overlay:SetParent(PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.HeroSpecButton)
	overlay:SetAllPoints()
end)
