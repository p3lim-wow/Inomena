local E, F, C = unpack(select(2, ...))

local tabs = {}
local function OnTabClick()
	for index, Tab in next, tabs do
		local current = IsCurrentSpell(Tab.name)
		Tab:SetChecked(current)
		Tab:SetButtonState(current and 'DISABLED' or 'NORMAL')
	end
end

local function CreateTab(name, texture, tooltip)
	local Tab = CreateFrame('CheckButton', C.Name .. 'ProfessionTab' .. (#tabs + 1), TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
	Tab:SetAttribute('type', 'spell')
	Tab:SetAttribute('spell', name)
	Tab:SetNormalTexture(texture)
	Tab:SetMotionScriptsWhileDisabled(true)
	Tab:HookScript('OnClick', OnTabClick)
	Tab.name = name
	Tab.tooltip = tooltip
	Tab:Show()

	if(#tabs == 0) then
		Tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, -36)
	else
		Tab:SetPoint('TOPLEFT', tabs[#tabs], 'BOTTOMLEFT', 0, -17)
	end

	tabs[#tabs + 1] = Tab
end

local offsetProfessions = {
	[182] = 1, -- Herbalism
	[186] = 1, -- Mining
	[393] = 1, -- Skinning
}

function E:ADDON_LOADED(addonName)
	if(addonName == 'Blizzard_TradeSkillUI') then
		for index, id in next, {GetProfessions()} do
			if(index ~= 4 and index ~= 3) then -- ignore fishing and archaeology
				local name, texture, rank, maxRank, numSpells, spellOffset, skillID = GetProfessionInfo(id)
				local tooltip = string.format(ITEM_SET_NAME, name, rank, maxRank)

				local offset = offsetProfessions[skillID]
				if(offset) then
					name = GetSpellBookItemName(spellOffset + offset, 'professions')
					texture = GetSpellBookItemTexture(spellOffset + offset, 'professions')
				end

				CreateTab(name, texture, tooltip)
			end
		end

		if(select(2, UnitClass('player')) == 'DEATHKNIGHT') then
			-- Runeforging
			if(IsSpellKnown(53428)) then
				local name, _, texture = GetSpellInfo(53428)
				CreateTab(name, texture, name)
			end
		end

		E:RegisterEvent('TRADE_SKILL_SHOW', OnTabClick)
		OnTabClick()

		return true
	end
end
