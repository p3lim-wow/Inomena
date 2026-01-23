local _, addon = ...

-- this binding is _mostly_ because the self-cast option for class buffs is broken

-- we cast this on the player by default because the default self-cast option breaks easily
local MACRO = '/cast [@target,exists,help][@player] %s'

local spellID = addon.CLASS_BUFF_SPELLS[addon.PLAYER_CLASS]
if spellID then
	local button = addon:CreateBindButton('Buff', 'SecureActionButtonTemplate')
	button:Bind('ALT-1')
	button:SetAttribute('type', 'macro')
	button:SetAttribute('macrotext', MACRO:format(C_Spell.GetSpellName(spellID)))
end
