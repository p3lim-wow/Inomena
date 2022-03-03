local _, addon = ...

-- swaps signature abilities on action buttons when changing covenants

local signatureAbilities = {
	[300728] = true, -- Venthyr - Door of Shadows
	[310143] = true, -- Night Fae - Soulshape
	[324631] = true, -- Necrolord - Fleshcraft
	[324739] = true, -- Kyrian - Summon Steward
}

function addon:LEARNED_SPELL_IN_TAB(spellID)
	if signatureAbilities[spellID] then
		for signatureAbilityID in next, signatureAbilities do
			if signatureAbilityID ~= spellID then
				local slotIDs = C_ActionBar.FindSpellActionButtons(signatureAbilityID)
				if slotIDs then
					for _, slotID in next, slotIDs do
						PickupSpell(spellID)
						if GetCursorInfo() then
							C_ActionBar.PutActionInSlot(slotID)
						end
					end
				end
			end
		end
	end
end
