local E, F, C = unpack(select(2, ...))

local MOD_ALTERNATE = '[mod:shift]'
local MOD_VENDOR = '[mod:alt]'

local STOP_MACRO = '/stopmacro [nooutdoors][mounted][vehicleui]'

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

local DISMOUNT = [[
/cancelform [form]
/leavevehicle [canexitvehicle]
/dismount [mounted]
]]

local function WaterWalkingSpell()
	if(IsSpellKnown(546)) then
		return 546 -- Shaman - Water Walking
	elseif(IsSpellKnown(3714)) then
		return 3714 -- Death Knight - Path of Frost
	end
end

local function IsHalloween()
	local month, day, _
	if(C.BfA) then
		_ = C_Calendar.GetDate()
		month = _.month
		day = _.monthDay
	else
		_, month, day = CalendarGetDate()
	end

	return month == 10 and day >= 18 or month == 11 and day == 1
end

local ownedMounts = {}
local vendorMounts = {
	[280] = 2, -- Traveler's Tundra Mammoth (Alliance)
	[284] = 2, -- Traveler's Tundra Mammoth (Horde)
	[460] = 1, -- Grand Expedition Yak
}

local lastNumMounts = 0
local function UpdateMountsList()
	if(#ownedMounts > 0) then
		for _, list in next, ownedMounts do
			table.wipe(list)
		end
	end

	for mountID, priority in next, vendorMounts do
		local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
		if(collected and not ineligible) then
			if(not ownedMounts.vendor or vendorMounts[ownedMounts.vendor] > priority) then
				ownedMounts.vendor = mountID
			end
		end
	end

	for _, mountID in next, C_MountJournal.GetMountIDs() do
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		if(mountType == 284 or mountType == 269) then
			if(not ownedMounts[mountType]) then
				ownedMounts[mountType] = {}
			end

			local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
			if(collected and not ineligible) then
				table.insert(ownedMounts[mountType], mountID)
			end
		end
	end
end

local mountMacro = '/run C_MountJournal.SummonByID(%s)'
local function PreClick()
	if(InCombatLockdown()) then
		return
	end

	local macro, mountID, spellID
	if(not select(13, GetAchievementInfo(891)) and #ownedMounts[284] > 0) then
		mountID =  ownedMounts[284][1]
	elseif(SecureCmdOptionParse(MOD_VENDOR) and ownedMounts.vendor) then
		mountID = ownedMounts.vendor
	elseif(SecureCmdOptionParse(MOD_ALTERNATE)) then
		spellID =  WaterWalkingSpell()
		if(not spellId and #ownedMounts[269] > 0) then
			mountID = ownedMounts[269][math.random(#ownedMounts[269])]
		end
	end

	if(not macro) then
		macro = STOP_MACRO

		if(spellID) then
			macro = strtrim(strjoin('\n', macro, '/cast ' .. GetSpellInfo(spellID)))
		end

		if(IsHalloween() and GetItemCount(37011) > 0) then
			-- Magic Broom time!
			macro = strtrim(strjoin('\n', macro, '/use item:37011'))
		else
			macro = strtrim(strjoin('\n', macro, string.format(mountMacro, mountID or 0)))
		end
	end

	Button:SetAttribute('macrotext', strtrim(strjoin('\n', DISMOUNT, macro)))
end

E:RegisterEvent('UPDATE_BINDINGS', SetBindings)
E:RegisterEvent('PLAYER_ENTERING_WORLD', SetBindings)

E:RegisterEvent('PLAYER_LOGIN', UpdateMountsList)
E:RegisterEvent('COMPANION_LEARNED', UpdateMountsList)
E:RegisterEvent('COMPANION_UNLEARNED', UpdateMountsList)
E:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', UpdateMountsList)

E:RegisterEvent('PLAYER_REGEN_ENABLED', PreClick)

Button:SetScript('PreClick', function()
	if(UnitOnTaxi('player')) then
		return TaxiRequestEarlyLanding()
	end

	PreClick()
end)
