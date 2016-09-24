local E = unpack(select(2, ...))

-- http://www.wowhead.com/artifact-calc
local artifactSpecs = {
	[128402] = 1, -- Death Knight, Blood - Maw of the Damned
	[128292] = 2, -- Death Knight, Frost - Blades of the Fallen Prince
	[128403] = 3, -- Death Knight, Unholy - Apocalypse
	[127829] = 1, -- Demon Hunter, Havoc - Twinblades of the Deceiver
	[128832] = 2, -- Demon Hunter, Vengeance - The Aldrachi Warblades
	[128858] = 1, -- Druid, Balance - Scythe of Elune
	[128860] = 2, -- Druid, Feral - Fangs of Ashamane
	[128821] = 3, -- Druid, Guardian - Claws of Ursoc
	[128306] = 4, -- Druid, Restoration - G'Hanir
	[128861] = 1, -- Hunter, Beast Mastery - Titanstrike
	[128826] = 2, -- Hunter, Marksmanship - Thas'dorah
	[128808] = 3, -- Hunter, Survival - Talonclaw
	[127857] = 1, -- Mage, Arcane - Aluneth
	[128820] = 2, -- Mage, Fire - Felo'melorn
	[128862] = 3, -- Mage, Frost - Ebonchill
	[128938] = 1, -- Monk, Brewmaster - Fu Zan
	[128937] = 2, -- Monk, Mistweaver - Sheilun
	[128940] = 3, -- Monk, Windwalker - Fists of the Heavens
	[128823] = 1, -- Paladin, Holy - The Silver Hand
	[128866] = 2, -- Paladin, Protection - Truthguard
	[120978] = 3, -- Paladin, Retribution - Ashbringer
	[128868] = 1, -- Priest, Discipline - Light's Wrath
	[128825] = 2, -- Priest, Holy - T'uure
	[128827] = 3, -- Priest, Shadow - Xal'atath
	[128870] = 1, -- Rogue, Assassination - The Kingslayers
	[128872] = 2, -- Rogue, Outlaw - The Dreadblades
	[128476] = 3, -- Rogue, Subtlety - Fangs of the Devourer
	[128935] = 1, -- Shaman, Elemental - The Fist of Ra-den
	[128819] = 2, -- Shaman, Enhancement - Doomhammer
	[128911] = 3, -- Shaman, Restoration - Sharas'dal
	[128942] = 1, -- Warlock, Affliction - Ulthalesh
	[128943] = 2, -- Warlock, Demonology - Skull of the Man'ari
	[128941] = 3, -- Warlock, Destruction - Scepter of Sargeras
	[128910] = 1, -- Warrior, Arms - Strom'kar
	[128908] = 2, -- Warrior, Fury - Warswords of the Valarjar
	[128289] = 3, -- Warrior, Protection - Scale of the Earth-Warder
	[133755] = 0, -- Fishing - Underlight Angler
}

local HIGHLIGHT_TEXTURE = [[Interface\Buttons\ButtonHilight-Square]]

local function GetArtifactLocations()
	local locations = {}

	for containerID = 0, NUM_BAG_SLOTS do
		local numContainerSlots = GetContainerNumSlots(containerID)
		if(numContainerSlots) then
			for slotID = 1, numContainerSlots do
				local _, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(containerID, slotID)
				if(quality == LE_ITEM_QUALITY_ARTIFACT) then
					local _, _, _, _, _, _, _, _, _, _, _, classID = GetItemInfo(itemID)
					if(classID == 2) then -- weapon
						local specIndex = artifactSpecs[itemID]
						locations[specIndex] = {containerID, slotID}
					end
				end
			end
		end
	end

	local itemID = GetInventoryItemID('player', INVSLOT_MAINHAND)
	if(itemID and artifactSpecs[itemID]) then
		local specIndex = artifactSpecs[itemID]
		locations[specIndex] = {-1, INVSLOT_MAINHAND}
	else
		itemID = GetInventoryItemID('player', INVSLOT_OFFHAND)
		if(itemID and artifactSpecs[itemID]) then
			local specIndex = artifactSpecs[itemID]
			locations[specIndex] = {-1, INVSLOT_OFFHAND}
		end
	end

	return locations
end

local tabs = {}
local function OnTabClick(self)
	if(self:GetChecked()) then
		local artifactLocation = GetArtifactLocations()[self.specIndex]
		if(artifactLocation) then
			local containerID, slotID = unpack(artifactLocation)
			if(containerID >= 0) then
				SocketContainerItem(containerID, slotID)
			else
				SocketInventoryItem(slotID)
			end

			return
		end
	end

	self:SetChecked(not self:GetChecked())
end

local function ArtifactUpdate(event, newItem)
	if(ArtifactFrame:IsVisible() and newItem) then
		local show = not C_ArtifactUI.IsAtForge()
		local artifactLocations = GetArtifactLocations()

		local artifactSpecIndex
		local mainID, offID = C_ArtifactUI.GetArtifactInfo()
		if(artifactSpecs[mainID]) then
			artifactSpecIndex = artifactSpecs[mainID]
		elseif(artifactSpecs[offID]) then
			artifactSpecIndex = artifactSpecs[offID]
		end

		for index, Tab in next, tabs do
			Tab:SetShown(show)

			if(show) then
				local artifactOwned = artifactLocations[index]
				Tab:SetChecked(artifactSpecIndex == index)
				Tab:GetNormalTexture():SetDesaturated(not artifactOwned)
				Tab:GetHighlightTexture():SetTexture(artifactOwned and HIGHLIGHT_TEXTURE or nil)
			end
		end
	end
end

local function CreateArtifactTab(index, name, texture)
	local Tab = CreateFrame('CheckButton', 'ARTTAB' .. index, ArtifactFrame, 'SpellBookSkillLineTabTemplate')
	Tab:SetPoint('TOPLEFT', ArtifactFrame, 'TOPRIGHT', 12, -36 - (49 * #tabs))
	Tab:SetNormalTexture(texture)
	Tab:SetScript('OnClick', OnTabClick)
	Tab.specIndex = index
	Tab.tooltip = name

	tabs[index] = Tab
end

local origArtifactTraitOnClick
local function ArtifactTraitOnClick(self, button, ...)
	if(IsModifiedClick('CHATLINK') and ChatEdit_GetActiveWindow()) then
		ChatEdit_InsertLink(GetSpellLink(self.spellID))
	else
		origArtifactTraitOnClick(self, button, ...)
	end
end

local origArtifactRelicOnClick
local function ArtifactRelicOnClick(self, slot)
	if(IsModifiedClick('CHATLINK') and ChatEdit_GetActiveWindow()) then
		for index = 1, #self.RelicSlots do
			if(self.RelicSlots[index] == slot) then
				ChatEdit_InsertLink(select(4, C_ArtifactUI.GetRelicInfo(index)))
				return
			end
		end
	else
		origArtifactRelicOnClick(self, slot)
	end
end

function E:ADDON_LOADED(addon)
	if(addon == 'Blizzard_ArtifactUI') then
		for index = 1, GetNumSpecializations() do
			local _, name, _, texture = GetSpecializationInfo(index)
			CreateArtifactTab(index, name, texture)
		end

		if(GetItemCount(133755) > 0) then
			-- Fishing artifact
			CreateArtifactTab(0, PROFESSIONS_FISHING, (GetSpellTexture(7620)))
		end

		E:RegisterEvent('ARTIFACT_UPDATE', ArtifactUpdate)

		origArtifactTraitOnClick = ArtifactPowerButtonMixin.OnClick
		ArtifactPowerButtonMixin.OnClick = ArtifactTraitOnClick

		origArtifactRelicOnClick = ArtifactTitleTemplateMixin.OnRelicSlotClicked
		ArtifactFrame.PerksTab.TitleContainer.OnRelicSlotClicked = ArtifactRelicOnClick

		return true
	end
end
