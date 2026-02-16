local addonName, addon = ...

-- restore previously equipped gear after equipping and using teleportation equipment,
-- like the guild cloaks

local equipmentCache = {}
local function updateEquipmentCache(inventorySlot)
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(inventorySlot)
	if itemLocation and itemLocation:IsValid() then
		equipmentCache[inventorySlot] = C_Item.GetItemGUID(itemLocation)
	else
		equipmentCache[inventorySlot] = nil
	end
end

function addon:OnLogin()
	-- store a list of all equipment
	for inventorySlot = 1, 19 do
		updateEquipmentCache(inventorySlot)
	end
end

local queuedInventorySlots = addon:T()
local function restoreEquipment()
	for _, inventorySlot in next, queuedInventorySlots do
		-- first check if there is a cached item
		if equipmentCache[inventorySlot] then
			-- then check if that cached item is in the bags
			local itemLocation = C_Item.GetItemLocation(equipmentCache[inventorySlot])
			if itemLocation then
				local bagID, slotIndex = itemLocation:GetBagAndSlot()
				if bagID and slotIndex then
					-- finally equipping the item
					ClearCursor()
					C_Container.PickupContainerItem(bagID, slotIndex)
					AutoEquipCursorItem()
				end
			end
		end
	end

	-- wipe the queue and unregister the event
	queuedInventorySlots:wipe()
	return true
end

local function IsOPieItem(itemID)
	-- just so I don't have to maintain two lists of the same items
	if not OPie then
		return
	end

	for _, slice in ipairs(OPie.CustomRings:GetDefaultDescription(addonName .. 'Teleport')) do
		if slice[1] == 'ring' then
			for _, ringSlice in ipairs(OPie.CustomRings:GetDefaultDescription(slice[2])) do
				if ringSlice[1] == 'item' and ringSlice[2] == itemID then
					return true
				end
			end
		elseif slice[1] == 'item' and slice[2] == itemID then
			return true
		end
	end
end

function addon:PLAYER_EQUIPMENT_CHANGED(inventorySlot)
	local itemID = GetInventoryItemID('player', inventorySlot)
	if IsOPieItem(itemID) then
		-- the equipped item is a teleportation item, queue the slot for re-equipping
		queuedInventorySlots:insert(inventorySlot)
		-- wait for next load screen
		if not self:IsEventRegistered('PLAYER_ENTERING_WORLD', restoreEquipment) then
			self:RegisterEvent('PLAYER_ENTERING_WORLD', restoreEquipment)
		end
	else
		-- item is not a teleportation item, update the cache
		updateEquipmentCache(inventorySlot)

		-- remove the item from the queue if it exists
		if queuedInventorySlots:contains(inventorySlot) then
			queuedInventorySlots:removeValue(inventorySlot)

			if #queuedInventorySlots == 0 then
				if self:IsEventRegistered('PLAYER_ENTERING_WORLD', restoreEquipment) then
					self:UnregisterEvent('PLAYER_ENTERING_WORLD', restoreEquipment)
				end
			end
		end
	end
end
