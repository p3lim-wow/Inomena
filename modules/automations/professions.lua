local _, addon = ...

-- automatically remove profession buffs

local PROFESSION_EQUIPMENT_BUFFS = {
	-- https://www.wowhead.com/spells/name-extended:Dressed+in+equipment
	388658, -- Blacksmithing
	391312, -- Tailoring
	391775, -- Cooking
	394001, -- Leatherworking
	394003, -- Alchemy
	394005, -- Herbalism
	394006, -- Mining
	394007, -- Engineering
	394008, -- Enchanting
	394011, -- Skinning
	394015, -- Jewelcrafting
	394016, -- Inscription

	-- extra
	391775, -- Chef's Hat (toy)
}

-- remove buff when profession window closes
addon:RegisterCallback('ProfessionsFrame.Hide', function()
	for _, spellID in next, PROFESSION_EQUIPMENT_BUFFS do
		if C_Secrets.ShouldAurasBeSecret() or C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
			addon:Defer(C_Spell.CancelSpellByID, spellID)
		end
	end
end)

local FISHING_EQUIPMENT_BUFFS = {
	394009, -- Fishing
	1303610, -- Fishing (another one? added in 12.1)
}

-- remove fishing equipment buff when taking off on a skyriding mount
addon:RegisterEvent('PLAYER_IS_GLIDING_CHANGED', function(_, isGliding)
	if isGliding then
		for _, spellID in next, FISHING_EQUIPMENT_BUFFS do
			if C_Secrets.ShouldAurasBeSecret() or C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
				addon:Defer(C_Spell.CancelSpellByID, spellID)
			end
		end
	end
end)
