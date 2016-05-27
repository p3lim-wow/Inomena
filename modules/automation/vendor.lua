local E, F = unpack(select(2, ...))

local lastNumItems = 0
local atMerchant
local function SellJunk()
	if(not atMerchant) then
		return
	end

	lastNumItems = 0

	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do
			local _, _, _, quality = GetContainerItemInfo(bag, slot)
			if(quality == LE_ITEM_QUALITY_POOR) then
				lastNumItems = lastNumItems + 1
				UseContainerItem(bag, slot)
			end
		end
	end
end

function E:MERCHANT_CLOSED()
	atMerchant = false
end

function E:MERCHANT_SHOW()
	atMerchant = true

	if(not IsShiftKeyDown()) then
		SellJunk()
	end
end

function E:BAG_UPDATE_DELAYED()
	if(lastNumItems > 0) then
		SellJunk()
	end
end
