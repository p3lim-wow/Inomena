local _, addon = ...

-- sound alerts to notify me of certain things (on the master channel)

local lastAlertTime = 0
local function alert()
	if GetTime() >= lastAlertTime + 10 then -- avoid spam
		lastAlertTime = GetTime()

		PlaySound(SOUNDKIT.READY_CHECK, 'master')
		-- FlashClientIcon()
	end
end

-- battleground queue pop
function addon:UPDATE_BATTLEFIELD_STATUS(index)
	if GetBattlefieldStatus(index) == 'confirm' then
		alert()
	end
end

-- lfg queue pop
function addon:LFG_LIST_APPLICATION_STATUS_UPDATED(_, status)
	if status == 'invited' then
		alert()
	end
end

-- readychecks
function addon:READY_CHECK()
	alert()
end

-- invites
addon:RegisterEvent('PARTY_INVITE_REQUEST', alert)
addon:RegisterEvent('LFG_PROPOSAL_SHOW', alert)

-- whisper notifications on the master channel
function addon:CHAT_MSG_WHISPER()
	PlaySound(SOUNDKIT.TELL_MESSAGE, 'master')
end

function addon:CHAT_MSG_BN_WHISPER()
	PlaySound(SOUNDKIT.TELL_MESSAGE, 'master')
end
