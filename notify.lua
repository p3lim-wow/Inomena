local _, Inomena = ...

Inomena.RegisterEvent('UPDATE_BATTLEFIELD_STATUS', function()
	if(StaticPopup_Visible('CONFIRM_BATTLEFIELD_ENTRY')) then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=], 'Master')
	end
end)

Inomena.RegisterEvent('LFG_PROPOSAL_SHOW', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=], 'Master')
end)

ReadyCheckListenerFrame:SetScript('OnShow', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=], 'Master')
end)
