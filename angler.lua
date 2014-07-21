local _, Inomena = ...

local hat
local pole = select(17, GetAuctionItemSubClasses(1))

Inomena.RegisterEvent('UNIT_INVENTORY_CHANGED', function(unit)
	if(unit ~= 'player') then return end

	local _, _, _, _, _, _, type = GetItemInfo(GetInventoryItemLink('player', 16) or 0)
	if(type == pole and not hat) then
		hat = GetInventoryItemLink('player', 1)

		if(GetItemCount(88710) and GetItemCount(88710) > 0) then
			EquipItemByName(88710)
		elseif(GetItemCount(33820) and GetItemCount(33820) > 0) then
			EquipItemByName(33820)
		elseif(GetItemCount(19972) and GetItemCount(19972) > 0) then
			EquipItemByName(19972)
		end
	elseif(type ~= pole and hat) then
		EquipItemByName(hat)
		hat = nil
	end
end)
