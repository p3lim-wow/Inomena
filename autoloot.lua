local _, Inomena = ...

local currentSlot

local ForceLoot = CreateFrame('Frame')
ForceLoot:Hide()
ForceLoot:SetScript('OnUpdate', function()
	ConfirmLootSlot(currentSlot)
end)

Inomena.RegisterEvent('LOOT_BIND_CONFIRM', function(slot)
	if(GetNumRaidMembers() == 0 or IsFishingLoot()) then
		currentSlot = slot
		ForceLoot:Show()
	end
end)

Inomena.RegisterEvent('LOOT_SLOT_CLEARED', function(slot)
	if(currentSlot == slot) then
		ForceLoot:Hide()

		local items = GetNumLootItems()
		if(items > 0) then
			for index = 1, items do
				return LootSlot(index)
			end
		end
	end
end)
