local E, F = unpack(select(2, ...))

local soundFile = [[Sound\Interface\ReadyCheck.ogg]]
function E:UPDATE_BATTLEFIELD_STATUS()
	if(StaticPopup_Visible('CONFIRM_BATTLEFIELD_ENTRY')) then
		PlaySoundFile(soundFile, 'Master')
	end
end

function E:LFG_PROPOSAL_SHOW()
	PlaySoundFile(soundFile, 'Master')
end

ReadyCheckListenerFrame:SetScript('OnShow', function()
	PlaySoundFile(soundFile, 'Master')
end)

function E:PARTY_INVITE_REQUEST()
	PlaySoundFile(soundFile, 'Master')
end

function E:LFG_LIST_APPLICATION_STATUS_UPDATED(_, status)
	if(status == 'invited') then
		PlaySoundFile(soundFile, 'Master')
	end
end

-- Brawler's Guild queue
function E:CHAT_MSG_RAID_BOSS_WHISPER(msg, name)
	if(name == UnitName('player') and msg == 'You are next in line!') then
		PlaySoundFile(soundFile, 'Master')
	end
end

-- Warn when spotting a rare
local recentlySpotted = {}
function E:VIGNETTE_ADDED(id)
	if(id and not recentlySpotted[id]) then
		local x, y, name, iconID = C_Vignettes.GetVignetteInfoFromInstanceID(id)
		if(iconID == 40) then
			return
		end

		name = name or 'Unknown Rare'

		RaidNotice_AddMessage(RaidWarningFrame, name .. ' spotted!', ChatTypeInfo.RAID_WARNING)
		PlaySoundFile(soundFile, 'Master')

		recentlySpotted[id] = true
	end
end
