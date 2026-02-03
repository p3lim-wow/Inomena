local _, addon = ...

-- (sound) alerts to notify me of certain things

-- battleground queue pop
function addon:UPDATE_BATTLEFIELD_STATUS(index)
	if GetBattlefieldStatus(index) == 'confirm' then
		C_Sound.PlaySound(SOUNDKIT.READY_CHECK, 'master', true)
	end
end

-- lfg queue pop
function addon:LFG_LIST_APPLICATION_STATUS_UPDATED(_, status)
	if status == 'invited' then
		C_Sound.PlaySound(SOUNDKIT.READY_CHECK, 'master', true)
	end
end

end

-- misc events we straight up trigger sounds for
for event, soundkitID in next, {
	CHAT_MSG_WHISPER = 'TELL_MESSAGE',
	CHAT_MSG_BN_WHISPER = 'TELL_MESSAGE',
	PARTY_INVITE_REQUEST = 'READY_CHECK',
	READY_CHECK = 'READY_CHECK',
	LFG_PROPOSAL_SHOW = 'READY_CHECK',
} do
	addon:RegisterEvent(event, function()
		C_Sound.PlaySound(SOUNDKIT[soundkitID], 'master', true)
	end)
end

-- display combat state changes
function addon:PLAYER_REGEN_ENABLED()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

function addon:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end
