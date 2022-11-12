local _, addon = ...

-- automatically repair at vendors
function addon:MERCHANT_SHOW()
	if CanMerchantRepair() and not IsShiftKeyDown() then
		local cost, canRepair = GetRepairAllCost()
		if canRepair then
			RepairAllItems(CanGuildBankRepair() and CanWithdrawGuildBankMoney() and GetGuildBankMoney() >= cost and GetGuildBankWithdrawMoney() >= cost)
			PlaySound(7994) -- SOUNDKIT.ITEM_REPAIR
		end
	end
end

-- track repair vendors if we're severely damaged
function addon:UPDATE_INVENTORY_DURABILITY()
	local alert = 0
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if status > alert then
			alert = status
		end
	end

	for index = 1, C_Minimap.GetNumTrackingTypes() do
		if C_Minimap.GetTrackingInfo(index) == MINIMAP_TRACKING_REPAIR then
			C_Minimap.SetTracking(index, alert > 0)
			break
		end
	end
end
