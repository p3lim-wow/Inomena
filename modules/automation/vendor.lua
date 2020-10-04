local E, F = unpack(select(2, ...))

local BACKPACK_CONTAINER = BACKPACK_CONTAINER or 0
local NUM_BAG_SLOTS = NUM_BAG_SLOTS or 4
-- local Enum.ItemQuality.Poor = Enum.ItemQuality.Poor or 0

local lastNumItems = 0
local function VendorGrayItems(merchantVisit)
	if not (merchantVisit or lastNumItems > 0) then
		return
	end

	lastNumItems = 0
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		for slotID = 1, GetContainerNumSlots(bagID) do
			if not MerchantFrame:IsShown() then
				-- this can take some time to iterate, and the player might close
				-- the window before it finishes
				return
			end

			local _, _, _, itemQuality, _, _, _, _, noValue = GetContainerItemInfo(bagID, slotID)
			if itemQuality == Enum.ItemQuality.Poor and not noValue then
				lastNumItems = lastNumItems + 1
				UseContainerItem(bagID, slotID)
			end
		end
	end
end

function E:MERCHANT_SHOW(recursive)
	if IsShiftKeyDown() then
		return
	end

	VendorGrayItems(true)
end

function E:BAG_UPDATE_DELAYED()
	VendorGrayItems()
end
