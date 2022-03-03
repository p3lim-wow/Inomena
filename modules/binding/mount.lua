local _, addon = ...

local MODIFIER_WATER = '[mod:shift]' -- for when underwater or when wanting to walk on it
local MODIFIER_VENDOR = '[mod:alt]'
local VENDOR_MOUNT_PRIORITY = {
	-- lower number = higher priority
	[280] = 3, -- Traveler's Tundra Mammoth (Alliance)
	[284] = 3, -- Traveler's Tundra Mammoth (Horde)
	[460] = 2, -- Grand Expedition Yak
	[1039] = 1, -- Mighty Caravan Brutosaur
}
local MAW = {
	[1543] = true,
	[1648] = true, -- intro
	[1961] = true, -- Korthia
}
local MAW_MOUNTS = {
	[1304] = true, -- Mawsworn Soulhunter
	[1441] = true, -- Bound Shadehound
	[1442] = true, -- Corridor Creeper
}
local WATERWALKING_EQUIPMENT = {
	[168416] = true, -- Angler's Water Striders
	[168417] = true, -- Inflatable Mount Shoes
}

local MACRO_ITEM = '/use item:%d'
local MACRO_CAST = '/cast %s'
local MACRO_MOUNT = '/run C_MountJournal.SummonByID(%d)'
local MACRO_STOP = '/stopmacro [mounted][vehicleui]'
local MACRO_START = [[
/leavevehicle [canexitvehicle]
/dismount [mounted]
]]

if addon.CLASS == 'DRUID' then
	MACRO_START = MACRO_START .. '\n/cancelform [form]'
end

local isHalloween = false
local specialMounts = {
	swimming = {},
	waterwalking = {},
	chauffeured = {},
	maw = {},
}

local function updateMounts()
	specialMounts.vendor = nil
	for _, tbl in next, specialMounts do
		if type(tbl) == 'table' then
			table.wipe(tbl)
		end
	end

	for mountID, priority in next, VENDOR_MOUNT_PRIORITY do
		local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
		if collected and not ineligible then
			if not specialMounts.vendor or VENDOR_MOUNT_PRIORITY[specialMounts.vendor] > priority then
				specialMounts.vendor = mountID
			end
		end
	end

	for _, mountID in next, C_MountJournal.GetMountIDs() do
		local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
		if collected and not ineligible then
			local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
			if mountType == 231 or mountType == 254 then
				-- turtle/swimming
				table.insert(specialMounts.swimming, mountID)
			elseif mountType == 269 then
				-- waterwalking
				table.insert(specialMounts.waterwalking, mountID)
			elseif mountType == 284 then
				-- chauffeured
				table.insert(specialMounts.chauffeured, mountID)
			elseif MAW_MOUNTS[mountID] then
				-- summon random mount iterates through _all_ mounts even in the maw,
				-- so we treat this as a special mount
				table.insert(specialMounts.maw, mountID)
			end
		end
	end
end

local function getMount()
	if not C_QuestLog.IsQuestFlaggedCompleted(63994) and MAW[C_Map.GetBestMapForUnit('player') or 0] and #specialMounts.maw > 0 then
		return specialMounts.maw[math.random(#specialMounts.maw)]
	elseif GetItemCount(174464) > 0 then
		-- Spectral Bridle in Torghast
		return nil, nil, 174464
	elseif GetItemCount(170499) > 0 then
		-- Maw Seeker Harness in Torghast
		return nil, nil, 170499
	elseif GetItemCount(168035) > 0 then
		-- Mawrat Harness in Torghast
		return nil, nil, 168035
	elseif not select(13, GetAchievementInfo(891)) then
		-- player has not trained riding yet
		return specialMounts.chauffeured[math.random(#specialMounts.chauffeured)]
	elseif SecureCmdOptionParse(MODIFIER_VENDOR) then
		-- vendor mounts are fixed by preference
		return specialMounts.vendor
	elseif SecureCmdOptionParse(MODIFIER_WATER) then
		if IsSwimming() and #specialMounts.swimming > 0 then
			-- TODO: handle Vashj'ir
			return specialMounts.swimming[math.random(#specialMounts.swimming)]
		elseif not WATERWALKING_EQUIPMENT[C_MountJournal.GetAppliedMountEquipmentID() or 0] then
			-- we don't have water walking equipment
			if IsSpellKnown(546) then
				-- Shamans have Water Walking, let them use a random mount
				return nil, 546, nil, true
			elseif IsSpellKnown(3714) then
				-- Death Knights have Path of Frost, let them use a random mount
				return nil, 3714, nil, true
			elseif #specialMounts.waterwalking > 0 then
				-- player has water walking mount, use that
				return specialMounts.waterwalking[math.random(#specialMounts.waterwalking)]
			end
		end
	elseif isHalloween and GetItemCount(37011) > 0 then
		-- prefer the instant-mount Magic Broom during that magic time of year
		return nil, nil, 37011
	end
end

local mount = addon:CreateButton('BindMount', nil, 'SecureActionButtonTemplate')
mount:SetAttribute('type', 'macro')
mount:RegisterEvent('COMPANION_LEARNED', updateMounts)
mount:RegisterEvent('COMPANION_UNLEARNED', updateMounts)
mount:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', updateMounts)
mount:RegisterEvent('PLAYER_LOGIN', function(self)
	SetBindingClick('HOME', self:GetName())

	-- check if it's Halloween
	local date = C_DateAndTime.GetCurrentCalendarTime()
	if (date.month == 10 and date.monthDay >= 18) or (date.month == 11 and date.monthDay == 1) then
		isHalloween = true

		if (date.monthDay == 18 and date.hour < 10) or (date.monthDay == 1 and date.hour > 11) then
			isHalloween = false
		end
	end

	-- set the default mount
	updateMounts()
	self:GetScript('PreClick')(self)

	return true
end)

local string_trim = string.trim
local string_join = string.join
mount:SetScript('PreClick', function(self)
	if UnitOnTaxi('player') then
		UIErrorsFrame:AddMessage('Requesting early landing.', 1, 1, 0)
		TaxiRequestEarlyLanding()
		return
	end

	if InCombatLockdown() then
		-- can't change macros in combat
		return
	end

	local mountID, spellID, itemID = getMount()
	local macro = MACRO_STOP

	if spellID then
		macro = string_trim(string_join('\n', macro, MACRO_CAST:format(GetSpellInfo(spellID))))
	end

	if itemID then
		macro = string_trim(string_join('\n', macro, MACRO_ITEM:format(itemID)))
	else
		macro = string_trim(string_join('\n', macro, MACRO_MOUNT:format(mountID or 0)))
	end

	self:SetAttribute('macrotext', string_trim(string_join('\n', MACRO_START, macro)))
end)
