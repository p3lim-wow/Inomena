local _, addon = ...

local lastAlertTime = 0
local function alert()
	if GetTime() >= lastAlertTime + 10 then -- avoid spam
		PlaySound(8960, 'master') -- SOUNDKIT.READY_CHECK
		-- FlashClientIcon()
		lastAlertTime = GetTime()
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

function addon:CHAT_MSG_RAID_BOSS_WHISPER(msg, name)
	-- Brawler's Guild queue
	if name == UnitName('player') and msg == 'You are next in line!' then
		alert()
	end
end

-- combat state changes
function addon:PLAYER_REGEN_ENABLED()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

function addon:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end

-- afk logout popup
function addon:CHAT_MSG_SYSTEM(msg)
	if msg == IDLE_MESSAGE then
		alert()
	end
end

-- readychecks
ReadyCheckListenerFrame:SetScript('OnShow', alert)

-- invites
addon:RegisterEvent('PARTY_INVITE_REQUEST', alert)
addon:RegisterEvent('LFG_PROPOSAL_SHOW', alert)
