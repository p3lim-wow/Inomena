local E, F = unpack(select(2, ...))

local lastAlert = 0
local soundFile = [[Sound\Interface\ReadyCheck.ogg]]
local function Alert()
	if(GetTime() >= lastAlert + 10) then
		PlaySoundFile(soundFile, 'Master')
		FlashClientIcon()
		lastAlert = GetTime()
	end
end

function E:UPDATE_BATTLEFIELD_STATUS()
	if(StaticPopup_Visible('CONFIRM_BATTLEFIELD_ENTRY')) then
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

E.PARTY_INVITE_REQUEST = Alert
E.LFG_PROPOSAL_SHOW = Alert
ReadyCheckListenerFrame:SetScript('OnShow', Alert)
