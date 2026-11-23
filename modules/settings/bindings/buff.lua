local _, addon = ...

-- this binding is _mostly_ because the self-cast option for class buffs is broken

-- we cast this on the player by default because the default self-cast option breaks easily
local MACRO = '/cast [@target,exists,help][@player] %s'

local buttons = {}
local function bind(spellID, index)
	if not index then
		index = 1
	end

	local button = buttons[index]
	if not button then
		button = addon:CreateBindButton('Buff' .. index, 'SecureActionButtonTemplate')
		button:Bind('ALT-' .. index)
		button:SetAttribute('type', 'macro')
		buttons[index] = button
	end

	button:SetAttribute('macrotext', MACRO:format(C_Spell.GetSpellName(spellID)))
end

local function useGroupSpells()
	if not addon:IsForever() then
		return false
	elseif C_SpellBook.IsSpellKnown(1225503) then
		return true
	elseif addon:IsInDungeon() and IsInGroup() then
		return true
	end
end

local function getKnownSpell(spellIdentifier)
	if type(spellIdentifier) == 'table' then
		for _, spellID in next, spellIdentifier do
			if C_SpellBook.IsSpellKnown(spellID) then
				return spellID
			end
		end
	elseif spellIdentifier and C_SpellBook.IsSpellKnown(spellIdentifier) then
		return spellIdentifier
	end
end

local function updateBinds()
	local buffs = addon.CLASS_BUFF_SPELLS[addon.PLAYER_CLASS]
	local groupBuffs = useGroupSpells() and addon.CLASS_BUFF_GROUP_SPELLS[addon.PLAYER_CLASS]

	local numButtons = math.max(groupBuffs and #groupBuffs or 0, buffs and #buffs or 0)
	for buttonIndex = 1, numButtons do
		local spellID = (groupBuffs and getKnownSpell(groupBuffs[buttonIndex]) or (buffs and getKnownSpell(buffs[buttonIndex])))
		if spellID then
			addon:Defer(bind, spellID, buttonIndex)
		end
	end
end

addon:RegisterEvent('SPELLS_CHANGED', updateBinds)

if addon:IsForever() then
	addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateBinds)
end
