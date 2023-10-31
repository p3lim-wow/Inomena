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

local SPELL_NAME = GetSpellInfo(SPELL_ID)
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

local lastTarget, lastTargetName
local function updateTarget()
	if InCombatLockdown() then
		addon:Defer(updateTarget)
		return
	end

	if not IsSpellKnown(SPELL_ID) then
		return
	end

	local unit = getGroupRoleUnit()
	if SPELL_ROLE == 'TANK' and not unit and UnitExists('pet') then
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

		if unitName ~= lastTargetName then
			-- TODO: remove this output once I'm comfortable with it
			local _, targetClass = UnitClass(unit)
			local targetNameColored = addon.colors.class[targetClass]:WrapTextInColorCode(unitName)
			local spellNameColored = WrapTextInColorCode(SPELL_NAME, 'ffffff00')
			addon:Print('Setting', targetNameColored, 'as', spellNameColored, 'target')
			lastTargetName = unitName
		end
	end
end

addon:RegisterEvent('GROUP_ROSTER_UPDATE', updateTarget)
addon:RegisterEvent('UNIT_PET', updateTarget)
addon:RegisterEvent('PET_BAR_UPDATE', updateTarget)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateTarget)
addon:RegisterEvent('SPELLS_CHANGED', updateTarget)
