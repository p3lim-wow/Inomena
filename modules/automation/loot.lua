local _, addon = ...

-- confirm loot rolls
function addon:CONFIRM_LOOT_ROLL(rollID, rollType)
	if rollType > 0 then
		ConfirmLootRoll(rollID, rollType)
	end
end

function addon:CONFIRM_DISENCHANT_ROLL(rollID, rollType)
	if rollType > 0 then
		ConfirmLootRoll(rollID, rollType)
	end
end
