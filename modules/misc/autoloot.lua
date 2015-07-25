local E = unpack(select(2, ...))

function E:CONFIRM_LOOT_ROLL(id, type)
	if(type > 0) then
		ConfirmLootRoll(id, type)
	end
end

function E:CONFIRM_DISENCHANT_ROLL(id, type)
	if(type > 0) then
		ConfirmLootRoll(id, type)
	end
end
