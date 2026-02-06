local addonName, addon = ...

-- adds a custom OPie action for housing teleportation

local function GetActionTooltip(button, tooltip)
	-- fake a spell tooltip
	tooltip:AddLine(button.name, 1, 1, 1)

	if button.cooldownTime then
		tooltip:AddDoubleLine(SPELL_CAST_TIME_SEC:format(button.castTime), SPELL_RECAST_TIME_MIN:format(button.cooldownTime), 1, 1, 1, 1, 1, 1)

		local cooldown = C_Housing.GetVisitCooldownInfo()
		if cooldown and not cooldown.isOnGCD and cooldown.duration > 0 then
			tooltip:AddLine(COOLDOWN_REMAINING .. ' ' .. SecondsToTime(cooldown.duration - (GetTime() - cooldown.startTime)), 1, 1, 1)
		end
	else
		tooltip:AddLine(SPELL_CAST_TIME_SEC:format(button.castTime), 1, 1, 1)
	end

	if button.neighborhoodGUID then
		local mapID
		if C_Housing.DoesFactionMatchNeighborhood(button.neighborhoodGUID) then
			if addon.PLAYER_FACTION_ID == Enum.PvPFaction.Horde then
				mapID = 2351
			elseif addon.PLAYER_FACTION_ID == Enum.PvPFaction.Alliance then
				mapID = 2352
			end
		else
			if addon.PLAYER_FACTION_ID == Enum.PvPFaction.Horde then
				mapID = 2352
			elseif addon.PLAYER_FACTION_ID == Enum.PvPFaction.Alliance then
				mapID = 2351
			end
		end

		if mapID then
			tooltip:AddLine('Teleports the player to their plot in ' .. C_Map.GetMapInfo(mapID).name .. '.')
		end
	end
end

local function GetActionDescription(button)
	local cooldownRemaining, cooldownLength = 0, 0
	if button.cooldownTime then
		local cooldownInfo = C_Housing.GetVisitCooldownInfo()
		if cooldownInfo then
			cooldownRemaining = cooldownInfo.timeUntilEndOfStartRecovery
			cooldownLength = cooldownInfo.duration
		end
	end

	return false, 0, button.icon, button.name, 1, cooldownRemaining, cooldownLength, GenerateClosure(GetActionTooltip, button), 0
end

local function GetActionSlotID(button)
	return button.actionSlotID
end

local function UpdateHouseButtons(_, housesInfo)
	local AB = OPie.ActionBook:compatible('ActionBook', 2, 51)

	for index, houseInfo in next, housesInfo do
		local button = CreateFrame('Button', nil, nil, 'SecureActionButtonTemplate')
		button:SetAttribute('useOnKeyDown', false)
		button:SetAttribute('type', 'teleporthome')
		button:SetAttribute('house-neighborhood-guid', houseInfo.neighborhoodGUID)
		button:SetAttribute('house-guid', houseInfo.houseGUID)
		button:SetAttribute('house-plot-id', houseInfo.plotID)
		button.name = HOUSING_DASHBOARD_TELEPORT_BUTTON_TEXT
		button.icon = 7252953 -- texture path from spellID 1263273
		button.castTime = 10
		button.cooldownTime = 15
		button.neighborhoodGUID = houseInfo.neighborhoodGUID
		button.actionSlotID = AB:CreateActionSlot(GenerateClosure(GetActionDescription, button), nil, 'attribute', 'type', 'click', 'clickbutton', button)
		AB:RegisterActionType('inomena.houseteleport' .. index, GenerateClosure(GetActionSlotID, button), nop, 1)
	end

	return true -- unregister event
end

addon:HookAddOn('OPie', function()
	local AB = OPie.ActionBook:compatible('ActionBook', 2, 51)

	-- add custom action for "return from neighborhood"
	local button = CreateFrame('Button', nil, nil, 'SecureActionButtonTemplate')
	button:SetAttribute('useOnKeyDown', false)
	button:SetAttribute('type', 'returnhome')
	button.name = HOUSING_DASHBOARD_RETURN
	button.icon = 'dashboard-panel-homestone-teleport-out-button'
	button.castTime = 10
	button.actionSlotID = AB:CreateActionSlot(GenerateClosure(GetActionDescription, button), nil, 'attribute', 'type', 'click', 'clickbutton', button)
	AB:RegisterActionType('inomena.housereturn', GenerateClosure(GetActionSlotID, button), nop, 1)

	-- pre-create custom ring for house teleport actions
	local ring = {}

	-- prefer the player's faction's neighborhood
	if addon.PLAYER_FACTION_ID == 0 then
		table.insert(ring, {'inomena.houseteleport2', c='FF2934', sliceToken='houseteleporthorde'})
		table.insert(ring, {'inomena.houseteleport1', c='00ADF0', sliceToken='houseteleportalliance'})
	elseif addon.PLAYER_FACTION_ID == 1 then
		table.insert(ring, {'inomena.houseteleport1', c='00ADF0', sliceToken='houseteleportalliance'})
		table.insert(ring, {'inomena.houseteleport2', c='FF2934', sliceToken='houseteleporthorde'})
	end

	-- inject ring
	OPie.CustomRings:SetExternalRing(addonName .. 'Home', ring)

	-- check for owned houses and create custom actions
	addon:RegisterEvent('PLAYER_HOUSE_LIST_UPDATED', UpdateHouseButtons)
	C_Housing.GetPlayerOwnedHouses() -- trigger PLAYER_HOUSE_LIST_UPDATED
end)
