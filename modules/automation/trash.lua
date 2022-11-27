local _, addon = ...

-- sell trash items when visiting vendor
local lastNumItems = 0
local function sellTrash(isInitialTrigger)
	if not (isInitialTrigger or lastNumItems > 0) then
		return
	end

	lastNumItems = 0
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
			if not isInitialTrigger and not MerchantFrame:IsShown() then
				-- this can take some time to iterate, and the player might close
				-- the window before it finishes
				return
			end

			local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
			if itemInfo and itemInfo.quality == Enum.ItemQuality.Poor and not itemInfo.hasNoValue then
				lastNumItems = lastNumItems + 1
				C_Container.UseContainerItem(bagID, slotID)
			end
		end
	end
end

function addon:MERCHANT_SHOW()
	if IsShiftKeyDown() then
		return
	end

	sellTrash(true)
end

function addon:BAG_UPDATE_DELAYED()
	sellTrash()
end
