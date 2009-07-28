local gear = cargoShip('Broker_Equipment', {noText = true})
gear:SetPoint('BOTTOMRIGHT', Minimap, -1, 1)
gear:SetScript('OnLeave', function() gear:SetAlpha(0) end)
gear:SetScript('OnEnter', function() gear:SetAlpha(1) end)
gear:SetAlpha(0)


local dps = cargoShip('Broker_SimpleDPS', {
	noShadow = true,
	noIcon = true,
	font = [=[Interface\AddOns\pMinimap\font.ttf]=],
	fontStyle = 'OUTLINE',
	fontSize = 13,
})
dps:SetPoint('BOTTOMLEFT', Minimap)
dps:SetScript('OnEnter', function() dps:SetAlpha(1) end)
dps:SetScript('OnLeave', function()
	if(not UnitAffectingCombat('player')) then
		dps:SetAlpha(0)
	end
end)

local function fadeText()
	if(UnitAffectingCombat('player')) then
		dps:SetAlpha(1)
	else
		dps:SetAlpha(0)
	end
end

Inomena:Register('PLAYER_REGEN_ENABLED', fadeText)
Inomena:Register('PLAYER_REGEN_DISABLED', fadeText)
fadeText()
