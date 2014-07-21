local _, Inomena = ...

local soundFile = [=[Sound\Interface\ReadyCheck.wav]=]

Inomena.RegisterEvent('UPDATE_BATTLEFIELD_STATUS', function()
	if(StaticPopup_Visible('CONFIRM_BATTLEFIELD_ENTRY')) then
		PlaySoundFile(soundFile, 'Master')
	end
end)

Inomena.RegisterEvent('LFG_PROPOSAL_SHOW', function()
	PlaySoundFile(soundFile, 'Master')
end)

ReadyCheckListenerFrame:SetScript('OnShow', function()
	PlaySoundFile(soundFile, 'Master')
end)

Inomena.RegisterEvent('PARTY_INVITE_REQUEST', function()
	PlaySoundFile(soundFile, 'Master')
end)

Inomena.RegisterEvent('CHAT_MSG_RAID_BOSS_WHISPER', function(msg, name)
	if(name == UnitName('player') and msg == 'You are next in line!') then
		PlaySoundFile(soundFile, 'Master')
	end
end)
