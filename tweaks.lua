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

Inomena.RegisterEvent('REPLACE_ENCHANT', function(...)
	for index = 1, STATICPOPUP_NUMDIALOGS do
		local popup = _G['StaticPopup' .. index]
		if(popup.which == 'REPLACE_ENCHANT') then
			StaticPopup_OnClick(popup, 1)
		end
	end
end)

StaticPopupDialogs.PARTY_INVITE.hideOnEscape = 0
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = 0

SLASH_TICKETGM1 = '/gm'
SlashCmdList.TICKETGM = ToggleHelpFrame

SLASH_JOURNAL1 = '/ej'
SlashCmdList.JOURNAL = ToggleEncounterJournal
