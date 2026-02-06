local _, addon = ...

-- smart(-ish) mount key

local MAPS = {
	Undermine = {
		[2346] = true, -- Undermine
		[2406] = true, -- Undermine (raid)
	},
	Maw = {
		[1543] = true,
		[1648] = true, -- intro section
		[1960] = true, -- part of a quest
		[1961] = true, -- Korthia
	},
	Argus = {
		[830] = true, -- Krokuun
		[885] = true, -- Antoran Wastes
		[882] = true, -- Eredath
	},
}

local SPECIAL_MOUNTS_AVAILABLE = {}
local SPECIAL_MOUNTS = {
	Maw = {
		1304, -- Mawsworn Soulhunter
		1441, -- Bound Shadehound
		1442, -- Corridor Creeper
	},
	Chauffeured = {
		678, -- horde
		679, -- alliance
	}
}

local MACRO = {
	Spell = '/cast %s', -- sadly /cast can't take IDs
	Item = '/use item:%d',
	Mount = '/run C_MountJournal.SummonByID(%d)',
}

local MACRO_PREFIX = [[
/leavevehicle [canexitvehicle]
/dismount [mounted]
/stopmacro [vehicleui,nocanexitvehicle]
/cancelform [known:197625/24858,noform:4][known:5487/2645,noknown:197625/24858,form]
]]

local function isMountEligible(mountID)
	if mountID then
		local _, _, _, _, _, _, _, isFactionSpecific, faction, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
		if isFactionSpecific and faction ~= addon.PLAYER_FACTION_ID then
			return false
		end

		return collected and not ineligible
	end
end

local function updateAvailableSpecialMounts()
	for kind, mounts in next, SPECIAL_MOUNTS do
		if SPECIAL_MOUNTS_AVAILABLE[kind] then
			SPECIAL_MOUNTS_AVAILABLE[kind]:wipe()
		else
			SPECIAL_MOUNTS_AVAILABLE[kind] = addon:T()
		end

		for _, mountID in next, mounts do
			if isMountEligible(mountID) then
				SPECIAL_MOUNTS_AVAILABLE[kind]:insert(mountID)
			end
		end
	end
end

addon:RegisterEvent('COMPANION_LEARNED', updateAvailableSpecialMounts)
addon:RegisterEvent('COMPANION_UNLEARNED', updateAvailableSpecialMounts)
addon:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', updateAvailableSpecialMounts)
addon:RegisterEvent('PLAYER_LOGIN', updateAvailableSpecialMounts)

local function generateMacro()
	local macro
	local mapID = addon:GetPlayerMapID()

	if MAPS.Undermine[mapID] and C_SpellBook.IsSpellKnown(1215279) then
		-- "G-99 Breakneck" in Undermine
		macro = MACRO.Spell:format(C_Spell.GetSpellName(460013))
	elseif MAPS.Maw[mapID] and not C_QuestLog.IsQuestFlaggedCompleted(63994) then
		-- player is in the Maw and hasn't completed the Korthia intro yet
		if #SPECIAL_MOUNTS_AVAILABLE.Maw > 0 then
			macro = MACRO.Mount:format(SPECIAL_MOUNTS_AVAILABLE.Maw:random())
		end
	elseif C_Item.GetItemCount(174464) > 0 then
		-- "Spectral Bridle" in Torghast
		macro = MACRO.Item:format(174464)
	elseif C_Item.GetItemCount(170499) > 0 then
		-- "Maw Seeker Harness" in Torghast
		macro = MACRO.Item:format(170499)
	elseif C_Item.GetItemCount(168035) > 0 then
		-- "Mawrat Harness" in Torghast
		macro = MACRO.Item:format(168035)
	elseif not select(13, GetAchievementInfo(891)) and #SPECIAL_MOUNTS_AVAILABLE.Chauffeured > 0 then
		-- player has not trained riding yet
		macro = MACRO.Mount:format(SPECIAL_MOUNTS_AVAILABLE.Chauffeured[1])
	else
		if UnitExists('target') then
			-- copy the mount the target uses, for fun :)
			for _, auraInfo in next, C_UnitAuras.GetUnitAuras('target', 'HELPFUL') do
				local mountID = C_MountJournal.GetMountFromSpell(auraInfo.spellId)
				if mountID ~= nil then -- this handles secrets perfectly fine
					macro = MACRO.Mount:format(mountID)
					break
				end
			end
		end

		if not macro then
			if addon:IsHalloween() and isMountEligible(1799) then
				-- prefer "Eve's Ghastly Rider" during Hallow's End (instant mount)
				macro = MACRO.Mount:format(1799)
			else
				-- default to random mount
				macro = MACRO.Mount:format(0)
			end
		end
	end

	return MACRO_PREFIX .. macro
end

local button = addon:CreateBindButton('Mount', 'SecureActionButtonTemplate')
button:Bind('HOME')
button:SetAttribute('type', 'macro')
button:SetScript('PreClick', function()
	if not HasFullControl() and MAPS.Argus[addon:GetPlayerMapID()] then
		-- prevent jank on Argus
		if not InCombatLockdown() then
			button:SetAttribute('macrotext', '')
		end
	elseif UnitOnTaxi('player') then
		-- request early landing
		UIErrorsFrame:AddMessage('Requesting early landing', 1, 1, 0)
		TaxiRequestEarlyLanding()
	else
		addon:DeferMethod(button, 'SetAttribute', 'macrotext', generateMacro())
	end
end)

-- update button whenever we change zones or the "usability" of mounts changes,
-- this is to enable mounts that are supposed to be used in instanced combat
local function updateState()
	addon:DeferMethod(button, 'SetAttribute', 'macrotext', generateMacro())
end

addon:RegisterEvent('ZONE_CHANGED', updateState)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateState)
addon:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', updateState)
