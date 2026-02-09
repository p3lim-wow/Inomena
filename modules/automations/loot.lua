local _, addon = ...

-- faster auto looting

local ticker
local lastLootSlot
local function AttemptLoot()
	if lastLootSlot > 0 then
		-- ensure it's something we can loot
		local slotType = GetLootSlotType(lastLootSlot)
		if slotType == Enum.LootSlotType.None then
			return
		end

		local _, _, _, _, _, isLocked = GetLootSlotInfo(lastLootSlot)
		if isLocked then
			return
		end

		-- loot the slot and move on
		LootSlot(lastLootSlot)

		lastLootSlot = lastLootSlot - 1
	else
		ticker:Cancel()
	end
end

local function StartLooting()
	if IsShiftKeyDown() then
		return
	end

	lastLootSlot = GetNumLootItems()
	if lastLootSlot == 0 then
		return
	end

	if ticker then
		ticker:Cancel()
	end

	-- loot fast!
	ticker = C_Timer.NewTicker(1/20, AttemptLoot, lastLootSlot + 1) -- overshoot to make sure
end

addon:RegisterEvent('LOOT_READY', StartLooting)
addon:RegisterEvent('LOOT_OPENED', StartLooting)

function addon:LOOT_CLOSED()
	if ticker then
		ticker:Cancel()
	end
end
