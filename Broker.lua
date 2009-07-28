local gear = cargoShip('Broker_Equipment', {
})
gear:SetPoint('BOTTOMRIGHT', Minimap)

local dps = cargoShip('Broker_SimpleDPS', {
})
dps:SetPoint('BOTTOMLEFT', Minimap)

local function onEvent()
	if(UnitAffectingCombat('player')) then
		dps:Show()
	else
		dps:Hide()
	end
end

Inomena:Register('PLAYER_REGEN_ENABLED', onEvent)
Inomena:Register('PLAYER_REGEN_DISABLED', onEvent)

gear:SetScript('OnLeave', function() gear:Hide() end)
gear:SetScript('OnEnter', function() gear:Show() end)
dps:SetScript('OnEnter', function() dps:Show() end)
dps:SetScript('OnLeave', function()
	if(not UnitAffectingCombat('player')) then
		dps:Hide()
	end
end)