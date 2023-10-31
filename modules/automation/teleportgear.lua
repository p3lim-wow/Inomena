local addonName, addon = ...

local inventorySlots = {}
local function cacheInventorySlot(inventorySlot)
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(inventorySlot)
	if itemLocation and itemLocation:IsValid() then
		-- item exists, store the GUID
		inventorySlots[inventorySlot] = C_Item.GetItemGUID(itemLocation)
	else
		-- item doesn't exist
		inventorySlots[inventorySlot] = nil
	end
end

local queuedInventorySlot
local function equipQueuedItem()
	-- get item location from queued slot's cached GUID
	local itemLocation = C_Item.GetItemLocation(inventorySlots[queuedInventorySlot])
	if itemLocation then
		-- get bag and slot from item location
		local bagID, slotIndex = itemLocation:GetBagAndSlot()
		if bagID and slotIndex then
			-- equip item from bags
			ClearCursor()
			C_Container.PickupContainerItem(bagID, slotIndex)
			AutoEquipCursorItem()
		end
	end

	queuedInventorySlot = nil
	return true
end

function addon:PLAYER_LOGIN()
	-- store equipment GUIDs
	for inventorySlot = 1, 19 do
		cacheInventorySlot(inventorySlot)
	end
end

function addon:PLAYER_EQUIPMENT_CHANGED(inventorySlot)
	-- get the itemID
	local itemID = GetInventoryItemID('player', inventorySlot)
	if addon.TELEPORT_IDS[itemID] then
		-- player equipped a teleportation item, queue the old item for re-equipment after zoning
		queuedInventorySlot = inventorySlot
		self:RegisterEvent('PLAYER_ENTERING_WORLD', equipQueuedItem)
	else
		-- update stored equipment GUID
		cacheInventorySlot(inventorySlot)
	end
end
