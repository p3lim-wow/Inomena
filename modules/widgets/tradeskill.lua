local _, addon = ...

local RUNEFORGING = 53428

local PROFESSION_OFFSET = {
	-- gathering professions have their trade skills in a different slot
	[182] = 1, -- Herbalism
	[186] = 1, -- Mining
	[393] = 1, -- Skinning
}

local PROFESSION_IGNORED_INDEX = {
	-- these professions have no trade skills
	[3] = true, -- Fishing
	[4] = true, -- Archaeology
}

local tabs = {}
local function updateTabs()
	for _, tab in next, tabs do
		local current = IsCurrentSpell(tab.name)
		tab:SetChecked(current)
		tab:SetButtonState(current and 'DISABLED' or 'NORMAL')
	end
end

local function createTab(name, texture, tooltip)
	local tab = addon:CreateCheckButton('TradeTab' .. name, TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
	tab:SetAttribute('type', 'spell')
	tab:SetAttribute('spell', name)
	tab:SetNormalTexture(texture)
	tab:SetMotionScriptsWhileDisabled(true)
	tab:HookScript('OnClick', updateTabs)
	tab.name = name
	tab.tooltip = tooltip
	tab:Show()

	if #tabs == 0 then
		tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, -36)
	else
		tab:SetPoint('TOPLEFT', tabs[#tabs], 'BOTTOMLEFT', 0, -17)
	end

	tabs[#tabs + 1] = tab
end

addon:HookAddOn('Blizzard_TradeSkillUI', function()
	for index, professionID in next, {GetProfessions()} do
		if not PROFESSION_IGNORED_INDEX[index] then
			local name, texture, _, _, _, spellOffset, skillID = GetProfessionInfo(professionID)
			local offset = PROFESSION_OFFSET[skillID]
			if offset then
				name = GetSpellBookItemName(spellOffset + offset, 'professions')
				texture = GetSpellBookItemTexture(spellOffset + offset, 'professions')
			end

			createTab(name, texture, name)
		end
	end

	if IsSpellKnown(RUNEFORGING) then
		local name, _, texture = GetSpellInfo(RUNEFORGING)
		createTab(name, texture, name)
	end

	-- update triggers
	addon:RegisterEvent('TRADE_SKILL_SHOW', updateTabs)
	updateTabs()
end)
