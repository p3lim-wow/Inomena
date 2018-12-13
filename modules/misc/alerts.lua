local E, F = unpack(select(2, ...))

local lastAlert = 0
local function Alert()
	if(GetTime() >= lastAlert + 10) then
		PlaySound(SOUNDKIT.READY_CHECK, 'master')
		FlashClientIcon()
		lastAlert = GetTime()
	end
end

function E:UPDATE_BATTLEFIELD_STATUS(index)
	if((GetBattlefieldStatus(index)) == 'confirm') then
		Alert()
	end
end

function E:LFG_LIST_APPLICATION_STATUS_UPDATED(_, status)
	if(status == 'invited') then
		Alert()
	end
end

-- Brawler's Guild queue
function E:CHAT_MSG_RAID_BOSS_WHISPER(msg, name)
	if(name == UnitName('player') and msg == 'You are next in line!') then
		Alert()
	end
end

-- Display combat state changes
function E:PLAYER_REGEN_ENABLED()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

function E:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end

E.PARTY_INVITE_REQUEST = Alert
E.LFG_PROPOSAL_SHOW = Alert
ReadyCheckListenerFrame:SetScript('OnShow', Alert)
