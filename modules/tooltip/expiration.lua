local _, addon = ...

local REMAINING_DAYS = _G.SPELL_TIME_REMAINING_DAYS:gsub('%%d', '%%d+') -- globalstring
local REMAINING_HOURS = _G.SPELL_TIME_REMAINING_HOURS:gsub('%%d', '%%d+')-- globalstring
local REMAINING_MIN = _G.SPELL_TIME_REMAINING_MIN:gsub('%%d', '%%d+') --- globalstring
local REMAINING_SEC = _G.SPELL_TIME_REMAINING_SEC:gsub('%%d', '%%d+') --- globalstring

local function auraSpellPredicate(predicate, _, _, _, _, _, _, _, _, _, _, _, spellID)
	return predicate == spellID
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(_, data)
	for _, line in next, data.lines do
		if
			line.leftText:match(REMAINING_DAYS) or
			line.leftText:match(REMAINING_HOURS) or
			line.leftText:match(REMAINING_MIN) or
			line.leftText:match(REMAINING_SEC)
		then
			-- we can't get the unit, index nor filter, so this will only ever support player buffs
			local found, _, _, _, _, expiration = AuraUtil.FindAura(auraSpellPredicate, 'player', 'HELPFUL', data.id)
			if found then
				_G['GameTooltipTextLeft' .. line.lineIndex]:SetText(addon:FormatAuraTime(expiration - GetTime()))
			end
		end
	end
end)
