local _, Inomena = ...

local hat
Inomena.RegisterEvent('TRADE_SKILL_SHOW', function()
	if(IsTradeSkillGuild() or IsTradeSkillLinked()) then
		return 
	elseif(GetTradeSkillLine() == PROFESSIONS_COOKING and GetItemCount(46349) > 0) then
		hat = GetInventoryItemLink('player', 1)
		EquipItemByName(46349)
	end
end)

Inomena.RegisterEvent('TRADE_SKILL_CLOSE', function()
	if(hat) then
		EquipItemByName(hat)
		hat = nil
	end
end)

Inomena.RegisterEvent('TRADE_SKILL_UPDATE', function()
	if(hat and GetTradeSkillLine() ~= PROFESSIONS_COOKING) then
		EquipItemByName(hat)
		hat = nil
	end
end)
