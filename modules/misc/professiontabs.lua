local E, F = unpack(select(2, ...))

local tabs = {}
function E:TRADE_SKILL_SHOW()
	if(InCombatLockdown()) then
		return
	end

	if(#tabs == 0) then
		for index, id in next, {GetProfessions()} do
			if(id and index ~= 4) then -- ignore fishing
				local name, texture, rank, maxRank = GetProfessionInfo(id)
				local Tab = CreateFrame('CheckButton', nil, TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
				Tab:SetAttribute('type', 'spell')
				Tab:SetAttribute('spell', name)
				Tab:SetNormalTexture(texture)
				Tab:SetID(index)
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
	end

	for index, Tab in next, tabs do
		Tab:SetChecked(IsCurrentSpell(Tab.name))
		if(Tab:GetID() ~= 3) then
			Tab:SetButtonState(Tab:GetChecked() and 'DISABLED' or 'NORMAL')
		end
	end
end
