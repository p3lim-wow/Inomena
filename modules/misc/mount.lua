local E, F, C = unpack(select(2, ...))

local MOD_WATER = '[mod:shift]'
local MOD_VENDOR = '[mod:alt]'

local MACRO_USE = '/use item:%d'
local MACRO_CAST = '/cast %s'
local MACRO_MOUNT = '/run C_MountJournal.SummonByID(%d)'
local MACRO_STOP = '/stopmacro [nooutdoors][mounted][vehicleui]'
local MACRO_START = [[
/cancelform [form]
/leavevehicle [canexitvehicle]
/dismount [mounted]
]]

local MAGIC_BROOM = 37011
local IS_HALLOWEEN = false
local function UpdateHalloween()
	local date = C_Calendar.GetDate()
	if((date.month == 10 and date.monthDay >= 18) or (date.month == 11 and date.monthDay == 1)) then
		IS_HALLOWEEN = true
	end

	return true
end

local MOUNT_TYPE_LAND = 230
local MOUNT_TYPE_FLYING = 248
local MOUNT_TYPE_TURTLE = 231
local MOUNT_TYPE_WATER = 254
local MOUNT_TYPE_WATER_WALKING = 269
local MOUNT_TYPE_HEIRLOOM = 284


local Button = CreateFrame('Button', C.Name .. 'MountButton', nil, 'SecureActionButtonTemplate')
Button:SetAttribute('type', 'macro')

local bindingString = string.format('CLICK %s:LeftButton', Button:GetName())
local function SetBindings()
	ClearOverrideBindings(Button)

	local first, second = GetBindingKey('DISMOUNT')
	if(first) then
		SetOverrideBinding(Button, false, first, bindingString)
	end

	if(second) then
		SetOverrideBinding(Button, false, second, bindingString)
	end
end

local mounts = {
	water = {},
	waterwalking = {},
	heirloom = {},
}

local vendorMounts = {
	[280] = 3, -- Traveler's Tundra Mammoth (Alliance)
	[284] = 3, -- Traveler's Tundra Mammoth (Horde)
	[460] = 2, -- Grand Expedition Yak
	[1039] = 1, -- Mighty Caravan Brutosaur
}

local function UpdateMounts()
	for _, value in next, mounts do
		if(type(value) == 'table') then
			table.wipe(value)
		end
	end

	for mountID, priority in next, vendorMounts do
		local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
		if(collected and not ineligible) then
			if(not mounts.vendor or vendorMounts[mounts.vendor] > priority) then
				mounts.vendor = mountID
			end
		end
	end

	for _, mountID in next, C_MountJournal.GetMountIDs() do
		local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
		if(collected and not ineligible) then
			local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
			if(mountType == MOUNT_TYPE_WATER or mountType == MOUNT_TYPE_TURTLE) then
				table.insert(mounts.water, mountID)
			elseif(mountType == MOUNT_TYPE_WATER_WALKING) then
				table.insert(mounts.waterwalking, mountID)
			elseif(mountType == MOUNT_TYPE_HEIRLOOM) then
				table.insert(mounts.heirloom, mountID)
			end
		end
	end
end

local function GetRandomMount(mountTable)
	return mountTable[math.random(#mountTable)]
end

local function PreClick()
	if(InCombatLockdown()) then
		return
	end

	local mountID, spellID, itemID
	if(not select(13, GetAchievementInfo(891))) then
		-- Giddy Up!
		mountID = GetRandomMount(mounts.heirloom)
	elseif(SecureCmdOptionParse(MOD_VENDOR) and mounts.vendor) then
		mountID = mounts.vendor
	elseif(SecureCmdOptionParse(MOD_WATER)) then
		if(IsSwimming() and #mounts.water > 0) then
			-- TODO: handle Vashj'ir
			-- normal swimming mounts are 135% speed in normal waters
			-- normal swimming mounts are 270% speed in vashj'ir
			-- druid travel form is 135% speed in normal waters
			-- vashj'ir seahorse is 371% in vashj'ir
			-- druid travel form is 607% in vashj'ir
			-- don't know about the Subdued Seahorse, don't have it
			-- don't know about the Saltwater Seahorse, don't have it
			mountID = GetRandomMount(mounts.water)
		else
			if(IsSpellKnown(546)) then
				-- Shaman - Water Walking
				spellID = 546
			elseif(IsSpellKnown(3714)) then
				-- Death Knight - Path of Frost
				spellID = 3714
			elseif(#mounts.waterwalking > 0) then
				mountID = GetRandomMount(mounts.waterwalking)
			end
		end
	elseif(IS_HALLOWEEN and GetItemCount(MAGIC_BROOM) > 0) then
		itemID = MAGIC_BROOM
	end

	macro = MACRO_STOP

	if(spellID) then
		macro = strtrim(strjoin('\n', macro, MACRO_CAST:format(GetSpellInfo(spellID))))
	end

	if(itemID) then
		macro = strtrim(strjoin('\n', macro, MACRO_USE:format(itemID)))
	else
		macro = strtrim(strjoin('\n', macro, MACRO_MOUNT:format(mountID or 0)))
	end

	Button:SetAttribute('macrotext', strtrim(strjoin('\n', MACRO_START, macro)))
end

E:RegisterEvent('UPDATE_BINDINGS', SetBindings)
E:RegisterEvent('PLAYER_ENTERING_WORLD', SetBindings)

E:RegisterEvent('PLAYER_LOGIN', UpdateHalloween)
E:RegisterEvent('PLAYER_LOGIN', UpdateMounts)
E:RegisterEvent('COMPANION_LEARNED', UpdateMounts)
E:RegisterEvent('COMPANION_UNLEARNED', UpdateMounts)
E:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', UpdateMounts)

E:RegisterEvent('PLAYER_REGEN_ENABLED', PreClick)

Button:SetScript('PreClick', function()
	if(UnitOnTaxi('player')) then
		UIErrorsFrame:AddMessage('Requesting early landing.', 1, 1, 0)
		return TaxiRequestEarlyLanding()
	end

	PreClick()
end)
