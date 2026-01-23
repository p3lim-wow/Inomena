local _, addon = ...

-- common binding for all healer mass resurrect spells

local button
local function updateState()
	local spellID = addon.CLASS_MASS_RESURRECT_SPELLS[addon.PLAYER_CLASS]
	if spellID then
		if C_SpellBook.IsSpellInSpellBook(spellID) then
			if not button then
				button = addon:CreateBindButton('Resurrect', 'SecureActionButtonTemplate')
				button:SetAttribute('type', 'spell')
				button:SetAttribute('spell', spellID)
			end

			button:Bind('ALT-R')
		elseif button then
			button:Unbind()
		end
	end
end

addon:RegisterEvent('PLAYER_LOGIN', updateState)
addon:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', function()
	addon:Defer(updateState)
end)
