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

local spells = addon.CLASS_BUFF_SPELLS[addon.PLAYER_CLASS]
if spells then
	function addon:SPELLS_CHANGED()
		if InCombatLockdown() then
			return
		end

		if type(spells) == 'table' then
			for index, spellID in next, spells do
				if type(spellID) == 'table' then
					for _, spell in next, spellID do
						if C_SpellBook.IsSpellKnown(spell) then
							bind(spell, index)
							break
						end
					end
				else
					bind(spellID, index)
				end
			end
		else
			bind(spells)
		end
	end
end
