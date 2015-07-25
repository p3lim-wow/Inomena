local E, F = unpack(select(2, ...))

function E:MERCHANT_SHOW()
	if(CanMerchantRepair() and not IsShiftKeyDown()) then
		RepairAllItems(CanGuildBankRepair() and CanWithdrawGuildBankMoney() and GetGuildBankWithdrawMoney() >= GetRepairAllCost())
	end
end
