local E = unpack(select(2, ...))

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
		origArtifactTraitOnClick = ArtifactPowerButtonMixin.OnClick
		ArtifactPowerButtonMixin.OnClick = ArtifactTraitOnClick

		origArtifactRelicOnClick = ArtifactTitleTemplateMixin.OnRelicSlotClicked
		ArtifactFrame.PerksTab.TitleContainer.OnRelicSlotClicked = ArtifactRelicOnClick

		return true
	end
end
