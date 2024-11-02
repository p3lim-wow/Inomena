local _, addon = ...

local SPELL_ID, SPELL_ROLE
if addon.PLAYER_CLASS == 'HUNTER' then
	SPELL_ID = 34477 -- Misdirection
	SPELL_ROLE = 'TANK'
elseif addon.PLAYER_CLASS == 'ROGUE' then
	SPELL_ID = 57934 -- Tricks of the Trade
	SPELL_ROLE = 'TANK'
elseif addon.PLAYER_CLASS == 'DRUID' then
	SPELL_ID = 29166 -- Innervate
	SPELL_ROLE = 'HEALER'
else
	return
end

local UNKNOWN = _G.UNKNOWN -- globalstring

local SPELL_NAME = (C_Spell.GetSpellName or GetSpellInfo)(SPELL_ID)
local MACRO = ('/stopcasting\n/cast [@%%s,help,nodead] %s'):format(SPELL_NAME)

local button = addon:BindButton('Misdirect', 'CTRL-F', 'SecureActionButtonTemplate')
button:SetAttribute('type', 'macro')

local function unitHasRole(unit, isRaid, raidIndex)
	if UnitGroupRolesAssigned(unit) == SPELL_ROLE then
		return true
	elseif isRaid then
		local _, _, _, _, _, _, _, _, _, _, _, combatRole = GetRaidRosterInfo(raidIndex)
		return combatRole == SPELL_ROLE
	end
	-- TODO: non-LFG role party check?
end

local function getGroupRoleUnit()
	local isRaid = IsInRaid()
	local prefix = isRaid and 'raid' or 'party'
	for index = 1, GetNumGroupMembers() do
		local unit = prefix .. index
		if unitHasRole(unit, isRaid, index) then
			return unit
		end
	end
end

local UnitTokenFromGUID = UnitTokenFromGUID or function(guid) -- classic
	if UnitGUID('player') == guid then
		return 'player'
	elseif UnitGUID('vehicle') == guid then
		return 'vehicle'
	elseif UnitGUID('pet') == guid then
		return 'pet'
	elseif IsInGroup() and not IsInRaid() then
		for index = 1, GetNumGroupMembers() do
			if UnitGUID('party' .. index) == guid then
				return 'party' .. index
			end
		end
		-- skipping pet check, not relevant for module
	elseif IsInRaid() then
		for index = 1, GetNumGroupMembers() do
			if UnitGUID('raid' .. index) == guid then
				return 'raid' .. index
			end
		end
		-- skipping pet check, not relevant for module
	end

	-- not gonna check for the rest of the supported targets for UnitTokenFromGUID as they're
	-- not relevant for this module
end

local lockedGUID, softGUID
local function printTarget()
	local unit = UnitTokenFromGUID(lockedGUID or softGUID or '')
	if unit then
		local coloredName = addon.colors.class[(UnitClassBase(unit))]:WrapTextInColorCode(UnitName(unit))
		local coloredSpell = WrapTextInColorCode(SPELL_NAME, 'ffffff00')
		addon:Print(coloredName, 'is', coloredSpell, 'target', lockedGUID and '|cff90ffff(locked)|r' or '')
	else
		local coloredSpell = WrapTextInColorCode(SPELL_NAME, 'ffffff00')
		addon:Print('No', coloredSpell, 'target')
	end
end

local function updateTarget()
	if InCombatLockdown() then
		addon:Defer(updateTarget)
		return
	end

	if not IsSpellKnown(SPELL_ID) then
		return
	end

	local unit
	if lockedGUID then
		unit = UnitTokenFromGUID(lockedGUID)
	else
		unit = getGroupRoleUnit()
	end

	if not unit and SPELL_ID == 34477 then
		if UnitExists('pet') then
			unit = 'pet'
		end
	end

	if not unit then
		return
	end

	local name = UnitName(unit)
	if not name or name == UNKNOWN then
		-- during loading/joining unit names aren't available yet
		return
	end

	button:SetAttribute('macrotext', MACRO:format(unit))

	local guid = UnitGUID(unit)
	if guid ~= softGUID then
		softGUID = guid
		printTarget()
	end
end

addon:RegisterEvent('GROUP_ROSTER_UPDATE', updateTarget)
addon:RegisterEvent('UNIT_PET', updateTarget)
addon:RegisterEvent('PET_BAR_UPDATE', updateTarget)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateTarget)
addon:RegisterEvent('SPELLS_CHANGED', updateTarget)

addon:RegisterSlash('/md', function()
	local guid = UnitExists('target') and UnitGUID('target')
	if guid and UnitIsUnit('target', 'player') then
		if lockedGUID ~= nil then
			local coloredSpell = WrapTextInColorCode(SPELL_NAME, 'ffffff00')
			addon:Print('Removing', coloredSpell, 'lock')
			lockedGUID = nil
			printTarget()
		end

		updateTarget()
	elseif guid and (IsGUIDInGroup(guid) or UnitIsUnit('target', 'pet')) then
		lockedGUID = guid
		updateTarget()
		printTarget()
	else
		printTarget()
	end
end)
