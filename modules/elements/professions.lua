local E, F, C = unpack(select(2, ...))

local tabs = {}
local function OnTabClick()
	for index, Tab in next, tabs do
		local current = IsCurrentSpell(Tab.name)
		Tab:SetChecked(current)
		Tab:SetButtonState(current and 'DISABLED' or 'NORMAL')
	end
end

function E:ADDON_LOADED(addonName)
	if(addonName == 'Blizzard_TradeSkillUI') then
		for index, id in next, {GetProfessions()} do
			if(id and index ~= 4 and index ~= 3) then -- ignore fishing and archaeology
				local name, texture, rank, maxRank, numSpells, spellOffset = GetProfessionInfo(id)

				if(numSpells > 1) then
					if(id == 7) then
						-- Herbalism
						name = GetSpellBookItemName(index + spellOffset, 'professions')
					end
				end

				local Tab = CreateFrame('CheckButton', C.Name .. 'ProfessionTab' .. index, TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
				Tab:SetAttribute('type', 'spell')
				Tab:SetAttribute('spell', name)
				Tab:SetNormalTexture(texture)
				Tab:SetMotionScriptsWhileDisabled(true)
				Tab:HookScript('OnClick', OnTabClick)
				Tab.name = name
				Tab.tooltip = string.format(ITEM_SET_NAME, name, rank, maxRank)

				if(#tabs == 0) then
					Tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, -36)
				else
					Tab:SetPoint('TOPLEFT', tabs[#tabs], 'BOTTOMLEFT', 0, -17)
				end
				Tab:Show()

				tabs[#tabs + 1] = Tab
			end
		end

		E:RegisterEvent('TRADE_SKILL_SHOW', OnTabClick)
		OnTabClick()

		return true
	end
end
