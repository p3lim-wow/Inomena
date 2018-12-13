local E, F, C = unpack(select(2, ...))

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

-- important party members death while playing Warlock/Druid/DK
if(C.playerClass == 'WARLOCK' or C.playerClass == 'DRUID' or C.playerClass == 'DEATHKNIGHT') then
	local ICON = '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t'
	local MESSAGE = string.format('%s |c%%s%%s|r %s', ICON, ICON)

	local players = {}
	local function CLEU()
		local _, event, _, _, _, _, _, guid, name = CombatLogGetCurrentEventInfo()
		if(event == 'UNIT_DIED' and players[guid]) then
			local playerClass = players[guid]
			local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[playerClass]:GenerateHexColor()

			PlaySound(SOUNDKIT.LFG_DENIED, 'master') -- need a better sound
			RaidNotice_AddMessage(RaidWarningFrame, MESSAGE:format(color, name), ChatTypeInfo.RAID_WARNING)
		end
	end

	local function AddPlayer(unit)
		local guid = UnitGUID(unit)
		if(guid) then
			local _, class = UnitClass(unit)
			players[guid] = class
		end
	end

	local function UpdateRoster()
		table.wipe(players)

		if(IsInRaid()) then
			-- add tanks and healers
			for index = 1, GetNumGroupMembers() do
				local _, _, _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(index)
				if(role == 'TANK' or role == 'HEALER') then
					AddPlayer('raid' .. index)
				end
			end
		elseif(IsInGroup()) then
			-- add everyone
			for index = 1, GetNumGroupMembers() do
				AddPlayer('party' .. index)
			end
		else
			if(E:IsEventRegistered('COMBAT_LOG_EVENT_UNFILTERED', CLEU)) then
				E:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', CLEU)
			end

			return
		end

		if(not E:IsEventRegistered('COMBAT_LOG_EVENT_UNFILTERED', CLEU)) then
			E:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', CLEU)
		end
	end

	E:RegisterEvent('GROUP_ROSTER_UPDATE', UpdateRoster)
	E:RegisterEvent('PLAYER_ENTERING_WORLD', UpdateRoster)
end

E.PARTY_INVITE_REQUEST = Alert
E.LFG_PROPOSAL_SHOW = Alert
ReadyCheckListenerFrame:SetScript('OnShow', Alert)
