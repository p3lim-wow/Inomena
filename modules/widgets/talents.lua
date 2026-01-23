local _, addon = ...

-- add custom specialization buttons and an override casting bar

local specButtons = {}
local function resetSpecButtons()
	for index, button in next, specButtons do
		button:SetChecked(index == C_SpecializationInfo.GetSpecialization())
	end

	OverlayPlayerCastingBarFrame:EndReplacingPlayerBar()
	PlayerSpellsFrame.TalentsFrame.DisabledOverlay:Hide()
end

local castbarOverrideInfo
local function onSpecButtonClick(self)
	resetSpecButtons()

	if not InCombatLockdown() and self:GetID() ~= C_SpecializationInfo.GetSpecialization() then
		C_SpecializationInfo.SetSpecialization(self:GetID())

		PlayerSpellsFrame.TalentsFrame.DisabledOverlay:Show()
		OverlayPlayerCastingBarFrame:StartReplacingPlayerBarAt(PlayerSpellsFrame.TalentsFrame.DisabledOverlay, castbarOverrideInfo)
	end
end

local function onSpecButtonEnter(self)
  GameTooltip:SetOwner(self, 'TOPRIGHT')
  GameTooltip:SetText((select(2, C_SpecializationInfo.GetSpecializationInfo(self:GetID()))))
  GameTooltip:Show()
end

addon:HookAddOn('Blizzard_PlayerSpells', function()
	local numSpecializations = GetNumSpecializations()

	-- anchor for buttons
	local anchor = addon:CreateFrame('Frame', nil, PlayerSpellsFrame.TalentsFrame)
	anchor:SetPoint('BOTTOM', PlayerSpellsFrame.TalentsFrame.ApplyButton, 'TOP', 0, 35)
	anchor:SetSize(numSpecializations * 45, 1)

	-- override info for castbar
	castbarOverrideInfo = {
		overrideBarType = 'applyingtalents',
		overrideAnchor = CreateAnchor('BOTTOM', PlayerSpellsFrame.TalentsFrame.DisabledOverlay, 'BOTTOM', 0, 80),
		overrideStrata = 'DIALOG',
	}

	for index = 1, numSpecializations do
		local button = addon:CreateButton('CheckButton', nil, anchor, 'ActionButtonTemplate')
		button:SetPoint('BOTTOMLEFT', 45 * (index - 1), 0)
		button:SetID(index)
		button:SetScript('OnClick', onSpecButtonClick)
		button:SetScript('OnEnter', onSpecButtonEnter)
		button:SetScript('OnLeave', GameTooltip_Hide)
		button:SetFrameStrata('HIGH')
		button:SetChecked(index == C_SpecializationInfo.GetSpecialization())
		button.icon:SetTexture((select(4, C_SpecializationInfo.GetSpecializationInfo(index))))

		table.insert(specButtons, button)
	end

	addon:RegisterEvent('SPECIALIZATION_CHANGE_CAST_FAILED', resetSpecButtons)
	addon:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED', resetSpecButtons)
end)
