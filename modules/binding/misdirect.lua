local _, addon = ...

local MISDIRECT_SPELL
if addon.PLAYER_CLASS == 'HUNTER' then
	MISDIRECT_SPELL = 34477 -- Misdirection
elseif addon.PLAYER_CLASS == 'ROGUE' then
	MISDIRECT_SPELL = 57934 -- Tricks of the Trade
else
	return
end

local MISDIRECT_SPELL_NAME = GetSpellInfo(MISDIRECT_SPELL)
local MACRO = ('/stopcasting\n/cast [@%%s,help,nodead] %s'):format(MISDIRECT_SPELL_NAME)

local button = addon:BindButton('Misdirect', 'CTRL-F', 'SecureActionButtonTemplate')
button:SetAttribute('type', 'macro')

local function isUnitTank(unit, isRaid, raidIndex)
	if UnitGroupRolesAssigned(unit) == 'TANK' then
		return true
	elseif isRaid then
		local _, _, _, _, _, _, _, _, _, _, _, combatRole = GetRaidRosterInfo(raidIndex)
		return combatRole == 'TANK'
	end
	-- TODO: non-LFG role party check?
end

local function getGroupTankUnit()
	local isRaid = IsInRaid()
	for index = 1, GetNumGroupMembers() do
		local unit = (isRaid and 'raid' or 'party') .. index
		if isUnitTank(unit, isRaid, index) then
			return unit
		end
	end
end

local lastTarget
local function updateTarget()
	if InCombatLockdown() then
		addon:Defer(updateTarget)
		return
	end

	if not IsSpellKnown(MISDIRECT_SPELL) then
		return
	end

	local unit = getGroupTankUnit()
	if not unit and UnitExists('pet') then
		unit = 'pet'
	end

	if not unit then
		return
	end

	local unitName = UnitName(unit)
	if not unitName or unitName == UNKNOWN then
		-- during loading/joining unit names aren't available yet
		return
	end

	if unit ~= lastTarget then
		lastTarget = unit
		button:SetAttribute('macrotext', MACRO:format(unit))

		-- TODO: remove this output once I'm comfortable with it
		local _, targetClass = UnitClass(unit)
		local targetNameColored = addon.colors.class[targetClass]:WrapTextInColorCode(unitName)
		local spellNameColored = WrapTextInColorCode(MISDIRECT_SPELL_NAME, 'ffffff00')
		addon:Print('Setting', targetNameColored, 'as', spellNameColored, 'target')
	end
end

addon:RegisterEvent('GROUP_ROSTER_UPDATE', updateTarget)
addon:RegisterEvent('UNIT_PET', updateTarget)
addon:RegisterEvent('PET_BAR_UPDATE', updateTarget)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateTarget)
addon:RegisterEvent('SPELLS_CHANGED', updateTarget)
