local _, addon = ...

-- automatically repair when interacting with a vendor that can do so

function addon:MERCHANT_SHOW()
	if not IsShiftKeyDown() and CanMerchantRepair() then
		local cost, isAvailable = GetRepairAllCost()
		if isAvailable and cost > 0 then
			-- TODO: there's no API to tell how much we have left to spend on repairs using guild
			--       money, but anything that can't be repaired with guild money will overflow into
			--       the player's wallet
			RepairAllItems(CanGuildBankRepair() and GetGuildBankMoney() >= cost)
		end
	end
end
