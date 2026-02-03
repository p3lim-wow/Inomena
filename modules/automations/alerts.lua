local _, addon = ...

-- (sound) alerts to notify me of certain things

-- battleground queue pop
function addon:UPDATE_BATTLEFIELD_STATUS(index)
	if GetBattlefieldStatus(index) == 'confirm' then
		C_Sound.PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE, 'master', true)
	end
end

-- lfg queue pop
function addon:LFG_LIST_APPLICATION_STATUS_UPDATED(_, status)
	if status == 'invited' then
		C_Sound.PlaySound(SOUNDKIT.READY_CHECK, 'master', true)
	end
end

-- afk logout
function addon:PLAYER_CAMPING()
	local success, isAFK = pcall(UnitIsAFK, 'player') -- stupid secrets
	if success and isAFK then
		C_Sound.PlaySound(SOUNDKIT.READY_CHECK, 'master', true)
	end
end

-- misc events we straight up trigger sounds for
for event, soundkitID in next, {
	CHAT_MSG_WHISPER = 'TELL_MESSAGE',
	CHAT_MSG_BN_WHISPER = 'TELL_MESSAGE',
	PARTY_INVITE_REQUEST = 'IG_PLAYER_INVITE',
	READY_CHECK = 'READY_CHECK',
	LFG_PROPOSAL_SHOW = 'READY_CHECK',
	LFG_READY_CHECK_SHOW = 'READY_CHECK',
	LFG_ROLE_CHECK_SHOW = 'READY_CHECK',
	ROLE_POLL_BEGIN = 'READY_CHECK',
	PET_BATTLE_QUEUE_PROPOSE_MATCH = 'PVP_THROUGH_QUEUE',
	START_PLAYER_COUNTDOWN = 'UI_COUNTDOWN_TIMER', -- why isn't this in "Gameplay Sound Effects"?
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
