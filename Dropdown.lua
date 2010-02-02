local menu = CreateFrame('Frame', 'kekekekkee') -- dummy namespace
menu:RegisterEvent('PARTY_LOOT_METHOD_CHANGED')
menu.displayMode = 'MENU'
menu.info = {}

local loot = {
	freeforall = 'Free for All',
	group = '|cff1eff00Group Loot|r',
	master = '|cff0070ddMaster Loot|r',
}

local globalloot = {
	needbeforegreed = 'Loot: %sNeed & Greed|r',
	freeforall = 'Loot: %sFree for All|r',
	group = 'Loot: %sGroup Loot|r',
	master = 'Loot: %sMaster Loot|r',
}

local party = {
	'5 |cffffff50Normal|r',
	'5 |cffff5050Heroic|r'
}

local raid = {
	'10 |cffffff50Normal|r',
	'25 |cffffff50Normal|r',
	'10 |cffff5050Heroic|r',
	'25 |cffff5050Heroic|r'
}

local function onEvent()
	if(CanGroupInvite() and GetLootMethod() ~= 'freeforall') then
		SetLootThreshold(GetLootMethod() == 'master' and 3 or 2)
	end
end

local function initialize(self, level)
	local info = self.info

	if(level == 1) then
		if(GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
			wipe(info)
			info.text = string.format(globalloot[GetLootMethod()], select(4, GetItemQualityColor(GetOptOutOfLoot() and 0 or GetLootThreshold())))
			info.notCheckable = 1
			info.func = function() if(IsShiftKeyDown()) then SetOptOutOfLoot(not GetOptOutOfLoot()) end end
			info.value = CanGroupInvite() and 'loot'
			info.hasArrow = CanGroupInvite() and 1
			UIDropDownMenu_AddButton(info, level)
		end

		wipe(info)
		info.text = string.format('Difficulty: %s', UnitInRaid('player') and raid[GetRaidDifficulty()] or party[GetDungeonDifficulty()])
		info.notCheckable = 1
		info.value = CanGroupInvite() and 'difficulty'
		info.hasArrow = CanGroupInvite() and 1
		UIDropDownMenu_AddButton(info, level)

		if(CanGroupInvite()) then
			wipe(info)
			info.text = RESET_INSTANCES
			info.notCheckable = 1
			info.func = function() ResetInstances() end
			UIDropDownMenu_AddButton(info, level)
		end

		if(GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
			wipe(info)
			info.text = PARTY_LEAVE
			info.notCheckable = 1
			info.func = function() LeaveParty() end
			UIDropDownMenu_AddButton(info, level)
		end
	elseif(level == 2) then
		if(UIDROPDOWNMENU_MENU_VALUE == 'loot') then
			wipe(info)

			for k, v in next, loot do
				info.text = v
				info.func = function() SetLootMethod(k, UnitName('player')) end
				UIDropDownMenu_AddButton(info, level)
			end
		elseif(UIDROPDOWNMENU_MENU_VALUE == 'difficulty') then
			wipe(info)

			if(UnitInRaid('player')) then
				for k, v in next, raid do
					info.text = v
					info.func = function() SetRaidDifficulty(k) end
					UIDropDownMenu_AddButton(info, level)
				end
			else
				for k, v in next, party do
					info.text = v
					info.func = function() SetDungeonDifficulty(k) end
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end
end

menu:SetScript('OnEvent', onEvent)
menu.initialize = initialize

-- Replace original dropdown with my custom one
_G['PlayerFrameDropDown'] = menu
