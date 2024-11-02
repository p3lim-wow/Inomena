local _, addon = ...

local SPECIAL_MOUNTS = {
	-- mounts that can be used at any level
	[678] = 'chauffeured', -- Chauffeured Mechano-Hog
	[679] = 'chauffeured', -- Chauffeured Mekgineer's Chopper

	-- mounts that will not get shot down in Mechagon
	[1227] = 'mechagon', -- Aerial Unit R-21/X
	[1254] = 'mechagon', -- Rustbolt Resistor
	[1813] = 'mechagon', -- Mimiron's Jumpjets

	-- mounts that are usable in The Maw before earning the rights to use all mounts there
	[1304] = 'maw', -- Mawsworn Soulhunter
	[1441] = 'maw', -- Bound Shadehound
	[1442] = 'maw', -- Corridor Creeper

	-- mounts that are fast on the ground, the air, and in water
	[1434] = 'hybrid', -- Deepstar Aurelid
	[1551] = 'hybrid', -- Cryptic Aurelid
	[1549] = 'hybrid', -- Shimmering Aurelid
	[1654] = 'hybrid', -- Otterworldly Ottuk Carrier

	-- instant mounts during halloween
	[1799] = 'halloween', -- Eve's Ghastly Rider
}

-- track which special mounts the player has collected and are eligible
local collectedSpecialMounts = {}
local function updateCollectedSpecialMounts()
	for _, tbl in next, collectedSpecialMounts do
		table.wipe(tbl)
	end

	for _, mountID in next, C_MountJournal.GetMountIDs() do
		local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
		local specialMountType = SPECIAL_MOUNTS[mountID]
		if specialMountType then
			if not collectedSpecialMounts[specialMountType] then
				collectedSpecialMounts[specialMountType] = {}
			end

			if collected and not ineligible then
				table.insert(collectedSpecialMounts[specialMountType], mountID)
			end
		end
	end
end

addon:RegisterEvent('COMPANION_LEARNED', updateCollectedSpecialMounts)
addon:RegisterEvent('COMPANION_UNLEARNED', updateCollectedSpecialMounts)
addon:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', updateCollectedSpecialMounts)
addon:RegisterEvent('PLAYER_LOGIN', updateCollectedSpecialMounts)

local Enum_MountType = {
	Mount = 1,
	Item = 2,
}

local MAW_ZONES = {
	-- zones considered to be part of The Maw
	[1543] = true,
	[1648] = true, -- intro
	[1960] = true, -- questing
	[1961] = true, -- Korthia
}

local ARGUS_ZONES = {
	[830] = true, -- Krokuun
	[885] = true, -- Antoran Wastes
	[882] = true, -- Eredath
}

local function isHalloween()
	local date = C_DateAndTime.GetCurrentCalendarTime()
	local dateNum = tonumber(string.format('%02d%02d%02d', date.month, date.monthDay, date.hour))
	return dateNum >= 101810 and dateNum <= 110811
end

local function getMount()
	-- Torghast item mounts
	if GetItemCount(174464) > 0 then
		-- Spectral Bridle in Torghast
		return 174464, Enum_MountType.Item
	elseif GetItemCount(170499) > 0 then
		-- Maw Seeker Harness in Torghast
		return 170499, Enum_MountType.Item
	elseif GetItemCount(168035) > 0 then
		-- Mawrat Harness in Torghast
		return 168035, Enum_MountType.Item
	end

	if not select(13, GetAchievementInfo(891)) and #collectedSpecialMounts.chauffeured > 0 then
		-- player has not trained riding yet
		return collectedSpecialMounts.chauffeured[math.random(#collectedSpecialMounts.chauffeured)], Enum_MountType.Mount
	end

	if isHalloween() then
		-- prefer the instant-mount Magic Broom during halloween
		if #collectedSpecialMounts.halloween > 0 then
			-- prefer the trained mount(s)
			return collectedSpecialMounts.halloween[math.random(#collectedSpecialMounts.halloween)], Enum_MountType.Mount
		elseif GetItemCount(37011) > 0 then
			-- fallback to the temporary mount
			return 37011, Enum_MountType.Item
		end
	end

	if playerMapID == 1462 and #collectedSpecialMounts.mechagon > 0 then
		-- prevent getting shot down in Mechagon
		return collectedSpecialMounts.mechagon[math.random(#collectedSpecialMounts.mechagon)], Enum_MountType.Mount
	end

	if playerMapID == 1355 and #collectedSpecialMounts.hybrid > 0 then
		-- I'm sick of swimming slow in Nazjatar
		return collectedSpecialMounts.hybrid[math.random(#collectedSpecialMounts.hybrid)], Enum_MountType.Mount
	end

	if not C_QuestLog.IsQuestFlaggedCompleted(63994) and MAW_ZONES[playerMapID] and #collectedSpecialMounts.maw > 0 then
		-- player is in the maw and haven't completed the Korthia intro yet
		return collectedSpecialMounts.maw[math.random(#collectedSpecialMounts.maw)]
	end

	return 0, Enum_MountType.Mount -- random favorite mount
end

local MACRO_MOUNT = '/run C_MountJournal.SummonByID(%d)'
local MACRO_ITEM = '/use item:%d'
local MACRO_STOP = '/stopmacro [mounted][vehicleui]'
local MACRO_START = [[
/leavevehicle [canexitvehicle]
/dismount [mounted]
]]

local mount = addon:BindButton('Mount', 'HOME', 'SecureActionButtonTemplate')
mount:SetAttribute('type', 'macro')

local function updateMountAttribute()
	if InCombatLockdown() then
		addon:Defer(updateMountAttribute)
		return
	end

	local playerMapID = addon:GetPlayerMapID()
	local _, _, _, _, canDragonride = C_MountJournal.GetMountInfoByID(1589)
	if addon.PLAYER_CLASS == 'DRUID' and not canDragonride then
		-- use flight form
		-- TODO: in 11.0 druids get dynamic flight form, drop the zone condition above
		mount:SetAttribute('macrotext', string.trim(string.join(
			'\n',
			MACRO_START,
			'/cast ' .. C_Spell.GetSpellName(783)
		)))
	else
		-- get a suitable mount
		local mountID, mountType = getMount()

		-- build the macro
		local macro = MACRO_STOP
		if mountType == Enum_MountType.Item then
			macro = string.trim(string.join('\n', macro, MACRO_ITEM:format(mountID)))
		elseif mountType == Enum_MountType.Mount then
			macro = string.trim(string.join('\n', macro, MACRO_MOUNT:format(mountID)))
		end

		if addon.PLAYER_CLASS == 'DRUID' then
			-- Travel Form if in combat, otherwise cancel all forms but Moonkin to mount
			mount:SetAttribute('macrotext', string.trim(string.join(
				'\n',
				MACRO_START,
				'/cast [combat]' .. C_Spell.GetSpellName(783),
				'/stopmacro [combat]',
				'/cancelform [known:197625/24858,noform:4][noknown:197625/24858,form]',
				macro
			)))
		else
			mount:SetAttribute('macrotext', string.trim(string.join('\n', MACRO_START, macro)))
		end
	end
end

mount:SetScript('PreClick', function()
	-- if the player is on a taxi path, request an early landing (ignore Argus "taxi")
	if UnitOnTaxi('player') and not ARGUS_ZONES[addon:GetPlayerMapID()] then
		UIErrorsFrame:AddMessage('Requesting early landing.', 1, 1, 0)
		TaxiRequestEarlyLanding()
		return
	end

	if not HasFullControl() and ARGUS_ZONES[addon:GetPlayerMapID()] then
		-- prevent jankyness in Argus
		mount:SetAttribute('macrotext', '')
		return
	end

	updateMountAttribute()
end)

-- extra updates for zone differences, usability etc
addon:RegisterEvent('ZONE_CHANGED', updateMountAttribute)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateMountAttribute)
addon:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', updateMountAttribute)
