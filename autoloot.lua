local _, Inomena = ...

local currentSlot
local specialItem = {
	[19807] = true, -- Speckled Tastyfish
	[19803] = true, -- Brownell's Blue Striped Racer
	[19806] = true, -- Dezian Queenfish
	[50289] = true, -- Blacktip Shark
}

local ForceLoot = CreateFrame('Frame')
ForceLoot:Hide()
ForceLoot:SetScript('OnUpdate', function()
	ConfirmLootSlot(currentSlot)
end)

Inomena.RegisterEvent('LOOT_BIND_CONFIRM', function(slot)
	local id = tonumber(string.match(GetLootSlotLink(slot), 'item:(%d+)'))
	if(id and (GetNumRaidMembers() == 0 or specialItem[id])) then
		currentSlot = slot
		ForceLoot:Show()
	end
end)

Inomena.RegisterEvent('LOOT_SLOT_CLEARED', function(slot)
	if(currentSlot == slot) then
		ForceLoot:Hide()
	end
end)
