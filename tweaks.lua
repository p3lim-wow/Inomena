local _, Inomena = ...

Inomena.RegisterEvent('MERCHANT_SHOW', function()
	if(CanMerchantRepair()) then
		RepairAllItems(CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= GetRepairAllCost())
	end
end)

Inomena.RegisterEvent('CONFIRM_LOOT_ROLL', function(id, type)
	if(type > 0) then
		ConfirmLootRoll(id, type)
	end
end)

Inomena.RegisterEvent('CONFIRM_DISENCHANT_ROLL', function(id, type)
	if(type > 0) then
		ConfirmLootRoll(id, type)
	end
end)

Inomena.RegisterEvent('PLAYER_REGEN_ENABLED', function()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end)

Inomena.RegisterEvent('PLAYER_REGEN_DISABLED', function()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end)

Inomena.RegisterEvent('ADDON_LOADED', function(addon)
	if(addon == 'Blizzard_AchievementUI') then
		AchievementFrame_SetFilter(3)
	end
end)

SLASH_TICKETGM1 = '/gm'
SlashCmdList.TICKETGM = ToggleHelpFrame

SLASH_JOURNAL1 = '/ej'
SlashCmdList.JOURNAL = function()
	ToggleFrame(EncounterJournal)
end
