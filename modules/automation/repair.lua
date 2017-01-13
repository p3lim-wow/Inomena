local E, F = unpack(select(2, ...))

function E:MERCHANT_SHOW()
	if(CanMerchantRepair() and not IsShiftKeyDown()) then
		local cost, canRepair = GetRepairAllCost()
		if(canRepair) then
			RepairAllItems(CanGuildBankRepair() and CanWithdrawGuildBankMoney() and GetGuildBankMoney() >= cost and GetGuildBankWithdrawMoney() >= cost)
			PlaySound('ITEM_REPAIR')
		end
	end
end
