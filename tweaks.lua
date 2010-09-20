local _, Inomena = ...

do
	local last
	Inomena.RegisterEvent('MAIL_SEND_SUCCESS', function()
		if(last) then
			SendMailNameEditBox:SetText(last)
			SendMailNameEditBox:HighlightText()
		end
	end)

	local orig = SendMailFrame_SendMail
	function SendMailFrame_SendMail(...)
		last = SendMailNameEditBox:GetText()
		orig(...)
	end
end

Inomena.RegisterEvent('MERCHANT_SHOW', function()
	if(CanMerchantRepair()) then
		RepairAllItems()
	end
end)

Inomena.RegisterEvent('UPDATE_BATTLEFIELD_STATUS', function()
	if(StaticPopup_Visible('CONFIRM_BATTLEFIELD_ENTRY')) then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
	end
end)

Inomena.RegisterEvent('LFG_PROPOSAL_SHOW', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)

ReadyCheckListenerFrame:SetScript('OnShow', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)

Inomena.RegisterEvent('PLAYER_REGEN_ENABLED', function()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end)

Inomena.RegisterEvent('PLAYER_REGEN_DISABLED', function()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end)

Inomena.RegisterEvent('PLAYER_ENTERING_WORLD', function()
	for key, value in pairs({
		lootUnderMouse = 0,
		autoLootDefault = 1,
		threatPlaySounds = 0,
		advancedWorldMap = 1,
		profanityFilter = 0,
		chatBubblesParty = 0,
		removeChatDelay = 1,
		guildRecruitmentChannel = 0,
		chatStyle = 'classic',
		conversationMode = 'inline',
		UnitNamePlayerGuild = 0,
		UnitNameGuildTitle = 0,
		UnitNamePlayerPVPTitle = 0,
		UnitNameFriendlyPetName = 0,
		UnitNameEnemyPetName = 0,
		nameplateShowFriendlyPets = 0,
		nameplateShowFriendlyGuardians = 0,
		nameplateShowFriendlyTotems = 0,
		nameplateShowEnemyPets = 0,
		nameplateShowEnemyGuardians = 0,
		nameplateShowEnemyTotems = 0,
		enableCombatText = 0,
		cameraWaterCollision = 0,
		cameraSmoothStyle = 0,
		showTutorials = 0,
		showNewbieTips = 0,

		synchronizeSettings = 0,
		processAffinityMask = 15,
		screenshotQuality = 10,
		useUiScale = 1,
		UIScale = 0.64,
		taintLog = 1,
	}) do
		SetCVar(key, value)
	end
end)


SLASH_TICKETGM1 = '/gm'
SlashCmdList.TICKETGM = ToggleHelpFrame

UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

UIParent:UnregisterEvent('PLAYER_LOGIN')
