local _, Inomena = ...

local currentSlot

local ForceLoot = CreateFrame('Frame')
ForceLoot:Hide()
ForceLoot:SetScript('OnUpdate', function()
	ConfirmLootSlot(currentSlot)
	StaticPopup_Hide('LOOT_BIND')
end)

Inomena.RegisterEvent('LOOT_BIND_CONFIRM', function(slot)
	if(GetNumGroupMembers() == 0 or IsFishingLoot()) then
		currentSlot = slot
		ForceLoot:Show()
	end
end)

Inomena.RegisterEvent('LOOT_SLOT_CLEARED', function(slot)
	if(currentSlot == slot) then
		ForceLoot:Hide()

		if(not IsModifiedClick('AUTOLOOTTOGGLE')) then
			local items = GetNumLootItems()
			if(items > 0) then
				for index = 1, items do
					LootSlot(index)
				end
			end
		end
	end
end)

Inomena.RegisterEvent('CONFIRM_LOOT_ROLL', function(id, type)
	if(type > 0) then
		ConfirmLootRoll(id, type)
	end
end)

Inomena.RegisterEvent('CONFIRM_DISENCHANT_ROLL', function(id, type)
	if(type > 0) then
		ConfirmLootRoll(id, type)
	end
end)
