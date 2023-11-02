local _, addon = ...

function addon:MERCHANT_SHOW()
	if IsShiftKeyDown() then
		return
	end

	if C_MerchantFrame.GetNumJunkItems() > 0 then
		C_MerchantFrame.SellAllJunkItems()
	end
end
