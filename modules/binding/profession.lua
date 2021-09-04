local _, addon = ...

local PROFESSION_OFFSETS = {
	-- gathering professions have their profession UIs in a different slot
	[182] = 1, -- Herbalism
	[186] = 1, -- Mining
	[393] = 1, -- Skinning
}

local profession = addon:CreateButton('BindProfession', nil, 'SecureActionButtonTemplate')
profession:SetAttribute('type', 'spell')
profession:RegisterEvent('SKILL_LINES_CHANGED', function(self)
	if InCombatLockdown() then
		-- can't change attributes in combat
		return
	end

	local primary, secondary = GetProfessions()
	if not primary then
		-- this should not happen
		primary = secondary
	end

	if primary then
		local name, _, _, _, _, spellOffset, skillID = GetProfessionInfo(primary)
		local offset = PROFESSION_OFFSETS[skillID]
		if offset then
			name = GetSpellBookItemName(spellOffset + offset, 'professions')
		end

		self:SetAttribute('spell', name)
	end
end)

profession:RegisterEvent('PLAYER_LOGIN', function(self)
	SetBindingClick('BACKSPACE', self:GetName())

	return true
end)
