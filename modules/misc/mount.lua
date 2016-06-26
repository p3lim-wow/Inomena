local E, F, C = unpack(select(2, ...))

local MOD_ALTERNATE = '[mod:shift]'
local MOD_VENDOR = '[mod:alt]'

local STOP_MACRO = '/stopmacro [nooutdoors][combat][mounted][vehicleui]'
local CORRAL_MACRO = '/cast [outdoors,combat,nomounted,novehicleui] %s'

local Button = CreateFrame('Button', (...) .. 'MountButton', nil, 'SecureActionButtonTemplate')
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

local function CorralOutpostAbility()
	if((HasDraenorZoneAbility or HasZoneAbility)()) then
		local ability = GetSpellInfo(161691)
		local _, _, _, _, _, _, spellID = GetSpellInfo(ability)
		if(spellID == 164222 or spellID == 165803) then
			return ability
		end
	end
end

local ownedMounts, GetMountMacro, UpdateMountsList = {}
if(C.isBetaClient) then
	local specialMounts = {
		vendor = {
			[280] = true, -- Traveler's Tundra Mammoth (Alliance)
			[284] = true, -- Traveler's Tundra Mammoth (Horde)
			[460] = true, -- Grand Expedition Yak
		},
		water = {
			[449] = true, -- Azure Water Strider
			[488] = true, -- Crimson Water Strider
		},
		chauferrued = {
			[678] = true, -- Chauffeured Mechano-Hog (Horde)
			[679] = true, -- Chauffeured Mekgineer's Chopper (Alliance)
		}
	}

	local lastNumMounts = 0
	function UpdateMountsList()
		table.wipe(ownedMounts)

		for category, mounts in next, specialMounts do
			for mountID in next, mounts do
				local _, _, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfoByID(mountID)
				if(collected and not ineligible) then
					if(not ownedMounts[category]) then
						ownedMounts[category] = {}
					end

					table.insert(ownedMounts[category], mountID)
				end
			end
		end
	end

	local mountMacro = '/run C_MountJournal.SummonByID(%s)'
	function GetMountMacro(mountID)
		return string.format(mountMacro, mountID)
	end
else
	local specialMounts = {
		vendor = {
			[61425] = true, -- Traveler's Tundra Mammoth (Alliance)
			[61447] = true, -- Traveler's Tundra Mammoth (Horde)
			[122708] = true, -- Grand Expedition Yak
		},
		water = {
			[118089] = true, -- Azure Water Strider
			[127271] = true, -- Crimson Water Strider
		},
		chauferrued = {
			[179244] = true, -- Chauffeured Mechano-Hog (Horde)
			[179245] = true, -- Chauffeured Mekgineer's Chopper (Alliance)
		}
	}

	local _mounts = {}
	local function UpdateLocalMountsList(...)
		for index = 1, C_MountJournal.GetNumMounts() do
			local name, spellID, _, _, _, _, _, _, _, ineligible, collected = C_MountJournal.GetMountInfo(index)
			if(spellID) then
				_mounts[spellID] = {name, ineligible, collected}
			end
		end
	end

	local function GetMountInfoBySpellID(spellID)
		local mount = _mounts[spellID]
		if(mount) then
			return mount[1], mount[2], mount[3]
		end
	end

	function UpdateMountsList()
		table.wipe(ownedMounts)

		UpdateLocalMountsList()

		for category, mounts in next, specialMounts do
			for spellID in next, mounts do
				local name, ineligible, collected = GetMountInfoBySpellID(spellID)
				if(collected and not ineligible) then
					if(not ownedMounts[category]) then
						ownedMounts[category] = {}
					end

					table.insert(ownedMounts[category], spellID)
				end
			end
		end
	end

	local randomMountMacro = '/run C_MountJournal.Summon(0)'
	function GetMountMacro(mountID)
		if(mountID == 0) then
			return randomMountMacro
		else
			return '/cast ' .. GetSpellInfo(mountID)
		end
	end
end

local function PreClick(...)
	if(InCombatLockdown()) then
		return
	elseif(UnitOnTaxi('player')) then
		return TaxiRequestEarlyLanding()
	end

	local macro, mountID, spellID
	if(not select(13, GetAchievementInfo(891)) and #ownedMounts.chauferrued > 0) then
		mountID =  ownedMounts.chauferrued[1]
	elseif(SecureCmdOptionParse(MOD_VENDOR) and #ownedMounts.vendor > 0) then
		mountID = ownedMounts.vendor[math.random(#ownedMounts.vendor)]
	elseif(SecureCmdOptionParse(MOD_ALTERNATE)) then
		local corralOutpostAbility = CorralOutpostAbility()
		if(corralOutpostAbility and not IsSubmerged()) then
			macro = '/cast ' .. corralOutpostAbility
		else
			spellID =  WaterWalkingSpell()

			if(spellID) then
				mountID = 0
			elseif(#ownedMounts.water > 0) then
				mountID = ownedMounts.water[math.random(#ownedMounts.water)]
			end
		end
	end

	if(not macro) then
		local corralOutpostAbility = CorralOutpostAbility()
		if(corralOutpostAbility) then
			macro = string.format(CORRAL_MACRO, corralOutpostAbility)
		end

		macro = strtrim(strjoin('\n', macro or '', STOP_MACRO))

		if(spellID) then
			macro = strtrim(strjoin('\n', macro, '/cast ' .. GetSpellInfo(spellID)))
		end

		macro = strtrim(strjoin('\n', macro, GetMountMacro(mountID or 0)))
	end

	Button:SetAttribute('macrotext', strtrim(strjoin('\n', DISMOUNT, macro)))
end

E.UPDATE_BINDINGS = SetBindings
E.PLAYER_ENTERING_WORLD = SetBindings

E.PLAYER_LOGIN = UpdateMountsList
E.COMPANION_LEARNED = UpdateMountsList
E.COMPANION_UNLEARNED = UpdateMountsList
E.MOUNT_JOURNAL_USABILITY_CHANGED = UpdateMountsList

E.ZONE_CHANGED_NEW_AREA = PreClick
E.PLAYER_REGEN_ENABLED = PreClick
Button:SetScript('PreClick', PreClick)
