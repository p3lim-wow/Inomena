local _, Inomena = ...

local button, hat
Inomena.RegisterEvent('TRADE_SKILL_SHOW', function()
	if(not button) then
		button = CreateFrame('Button', 'FireButton', TradeSkillFrame, 'SecureActionButtonTemplate')
		button:SetPoint('RIGHT', TradeSkillFrameCloseButton, 'LEFT', -235, 0)
		button:SetSize(20, 20)

		local name, _, icon = GetSpellInfo(818)
		button:SetAttribute('type', 'spell')
		button:SetAttribute('spell', name)
		button:SetNormalTexture(icon)
	end

	if(IsTradeSkillGuild() or IsTradeSkillLinked()) then
		button:Hide()
	elseif(GetTradeSkillLine() == PROFESSIONS_COOKING) then
		button:Show()

		if(GetItemCount(46349) and GetItemCount(46349) > 0) then
			hat = GetInventoryItemLink('player', 1)
			EquipItemByName(46349)
		end
	else
		button:Hide()
	end
end)

Inomena.RegisterEvent('TRADE_SKILL_CLOSE', function()
	if(hat) then
		EquipItemByName(hat)
		hat = nil
	end
end)

Inomena.RegisterEvent('TRADE_SKILL_UPDATE', function()
	if(GetTradeSkillLine() ~= PROFESSIONS_COOKING) then
		if(hat) then
			EquipItemByName(hat)
			hat = nil
		end

		if(button) then
			button:Hide()
		end
	end
end)
