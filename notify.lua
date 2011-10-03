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

local roster = {}
Inomena.RegisterEvent('PARTY_INVITE_REQUEST', function(name)
	if(roster[name]) then
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=], 'Master')
	end
end)

Inomena.RegisterEvent('GUILD_ROSTER_UPDATE', function()
	for index = 1, GetNumGuildMembers() do
		roster[GetGuildRosterInfo(index)] = true
	end
end)

GuildRoster()
