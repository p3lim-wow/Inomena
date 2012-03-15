local _, Inomena = ...

local hat, shoe
local pole = select(17, GetAuctionItemSubClasses(1))

Inomena.RegisterEvent('UNIT_INVENTORY_CHANGED', function(unit)
	if(unit ~= 'player') then return end

	local _, _, _, _, _, _, type = GetItemInfo(GetInventoryItemLink('player', 16) or 0)
	if(type == pole and not hat) then
		hat = GetInventoryItemLink('player', 1)
		shoe = GetInventoryItemLink('player', 8)

		if(GetItemCount(33820) and GetItemCount(33820) > 0) then
			EquipItemByName(33820)
		elseif(GetItemCount(19972) and GetItemCount(19972) > 0) then
			EquipItemByName(19972)
		end

		if(GetItemCount(50287) and GetItemCount(50287) > 0) then
			EquipItemByName(50287)
		elseif(GetItemCount(19969) and GetItemCount(19969) > 0) then
			EquipItemByName(19969)
		end
	elseif(type ~= pole and (hat or shoe)) then
		EquipItemByName(hat)
		EquipItemByName(shoe)
		hat, show = nil, nil
	end
end)
