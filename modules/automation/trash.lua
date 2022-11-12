local _, addon = ...

local GetContainerItemInfo = _G.GetContainerItemInfo or C_Container.GetContainerItemInfo -- BETA
local GetContainerNumSlots = _G.GetContainerNumSlots or C_Container.GetContainerNumSlots -- BETA
local UseContainerItem = _G.UseContainerItem or C_Container.UseContainerItem -- BETA

-- sell trash items when visiting vendor
local lastNumItems = 0
local function sellTrash(isInitialTrigger)
	if not (isInitialTrigger or lastNumItems > 0) then
		return
	end

	lastNumItems = 0
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		for slotID = 1, GetContainerNumSlots(bagID) do
			if not isInitialTrigger and not MerchantFrame:IsShown() then
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

function addon:MERCHANT_SHOW()
	if IsShiftKeyDown() then
		return
	end

	sellTrash(true)
end

function addon:BAG_UPDATE_DELAYED()
	sellTrash()
end
