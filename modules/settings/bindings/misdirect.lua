local _, addon = ...

-- smart(-ish) misdirect/tricks key

local SPELL_ID = ({
	HUNTER = 34477, -- Misdirection
	ROGUE = 57934, -- Tricks of the Trade
})[addon.PLAYER_CLASS]

if not SPELL_ID then
	return
end

local button = addon:CreateBindButton('Misdirect', 'SecureActionButtonTemplate')
button:Bind('CTRL-F')
button:SetAttribute('type', 'spell')
button:SetAttribute('spell', SPELL_ID)

local function unitIsTank(unit, isRaid, raidIndex)
	if UnitGroupRolesAssigned(unit) == 'TANK' then
		return true
	elseif isRaid then
		local _, _, _, _, _, _, _, _, _, _, _, combatRole = GetRaidRosterInfo(raidIndex)
		return combatRole == 'TANK'
	end
end

local function getTankUnit()
	local isRaid = IsInRaid()
	local unitPrefix = isRaid and 'raid' or 'party'
	for index = 1, GetNumGroupMembers() do
		local unit = unitPrefix .. index
		if unitIsTank(unit, isRaid, index) then
			return unit
		end
	end
end

local lastName, forcedGUID
local function updateTarget()
	if InCombatLockdown() then
		addon:Defer(updateTarget)
		return
	end

	if not C_SpellBook.IsSpellInSpellBook(SPELL_ID) then
		-- in case the player hasn't learned the spell yet
		return
	end

	local unit
	if forcedGUID then
		unit = UnitTokenFromGUID(forcedGUID)

		if not unit or not UnitExists(unit) then
			forcedGUID = nil

			-- try again
			updateTarget()
		end
	else
		unit = getTankUnit()
	end

	if not unit and addon.PLAYER_CLASS == 'HUNTER' and UnitExists('pet') then
		unit = 'pet'
	end

	if not unit or UnitInVehicle(unit) then
		return
	end

	local name = UnitName(unit)
	if not name or name == UNKNOWN then
		-- unit names aren't cached during loading/joining
		return
	end

	button:SetAttribute('unit', unit)

	if name ~= lastName then
		local _, class = UnitClass(unit)
		local coloredName = addon.colors.class[class]:WrapTextInColorCode(name)
		local coloredSpell = WrapTextInColorCode(C_Spell.GetSpellName(SPELL_ID), 'ffffff00')
		addon:Print(coloredName, 'is', coloredSpell, 'target', forcedGUID and '|cff90ffff(forced)|r' or '')

		lastName = name
	end
end

addon:RegisterEvent('GROUP_ROSTER_UPDATE', updateTarget)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateTarget)
addon:RegisterEvent('SPELLS_CHANGED', updateTarget)
addon:RegisterEvent('PET_BAR_UPDATE', updateTarget)
addon:RegisterUnitEvent('UNIT_PET', 'player', updateTarget)

-- provide a way to override the automation
addon:RegisterSlash('/md', function()
	local unit = 'target'
	local unitGUID = UnitExists(unit) and UnitGUID(unit)
	forcedGUID = unitGUID and (IsGUIDInGroup(unitGUID) or UnitIsUnit(unit, 'pet')) and unitGUID
	updateTarget()
end)
