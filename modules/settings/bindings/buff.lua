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

local function updateSpells()
	if InCombatLockdown() then
		return
	end

	local bestSpellID
	if addon:IsForever() and addon:IsInDungeon() and IsInGroup() and not addon:IsInRaid() then
		-- Forever has group-wide spells that should be used when in grouped dungeon content,
		-- but limit it to raids as buffing 5 people is better than the reagent cost.
		-- this might change in the future with Legacy unlocks to remove the reagent cost.
		local groupSpell = addon.CLASS_BUFF_GROUP_SPELLS[addon.PLAYER_CLASS]
		if groupSpell then
			if type(groupSpell) == 'table' then
				for _, spellID in ipairs(groupSpell) do
					if C_SpellBook.IsSpellKnown(spellID) then
						bestSpellID = spellID
						break
					end
				end
			elseif C_SpellBook.IsSpellKnown(groupSpell) then
				bestSpellID = groupSpell
			end
		end
	end

	if not bestSpellID then
		local spell = addon.CLASS_BUFF_SPELLS[addon.PLAYER_CLASS]
		if spell then
			if type(spell) == 'table' then
				for _, spellID in ipairs(spell) do
					if C_SpellBook.IsSpellKnown(spellID) then
						bestSpellID = spellID
						break
					end
				end
			elseif C_SpellBook.IsSpellKnown(spell) then
				bestSpellID = spell
			end
		end
	end

	if bestSpellID then
		bind(bestSpellID)
	end

	-- if type(spells) == 'table' then
	-- 	for index, spellID in next, spells do
	-- 		if type(spellID) == 'table' then
	-- 			for _, spell in next, spellID do
	-- 				if C_SpellBook.IsSpellKnown(spell) then
	-- 					bind(spell, index)
	-- 					break
	-- 				end
	-- 			end
	-- 		else
	-- 			bind(spellID, index)
	-- 		end
	-- 	end
	-- else
	-- 	bind(spells)
	-- end
end

addon:RegisterEvent('SPELLS_CHANGED', updateSpells)

if addon:IsForever() then
	addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateSpells)
end
