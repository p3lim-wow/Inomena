local _, addon = ...

-- vendor trash when interacting with a vendor

function addon:MERCHANT_SHOW()
	if not IsShiftKeyDown() and C_MerchantFrame.GetNumJunkItems() > 0 then
		C_MerchantFrame.SellAllJunkItems()
	end
end
