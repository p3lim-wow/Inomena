local _, addon = ...

-- track account-wide played time (because I hate myself)

local AVG_VALUE = '%.2f hours/day'

local accountInfo = C_BattleNet.GetGameAccountInfoByGUID(UnitGUID('player'))
local regionID = accountInfo and accountInfo.regionID
if not regionID then
	error('Unable to determine region')
	return
end

local LAUNCH_DATE
if addon:IsForever() then
	LAUNCH_DATE = 1793833200 -- November 4th 2026
elseif addon:IsRetail() then
	local dates = {
		1101186000, -- US: November 23rd 2004
		1105974000, -- KR: January 18th 2005
		1108076400, -- EU: Febrary 11th 2005
		1131379200, -- TW: November 8th 2005
		1118146800, -- CN: June 7th 2005
	}
	LAUNCH_DATE = dates[regionID]
elseif addon:IsClassic() then
	LAUNCH_DATE = 1566856800 -- August 26th 2019
end

local sessionStart, playerIdentifier
function addon:OnLogin()
	sessionStart = GetTime()

	if addon:IsForever() then
		local name, surname = UnitName('player')
		playerIdentifier = name .. '_' .. surname
	else
		playerIdentifier = GetRealmName() .. '-' .. UnitName('player')
	end

	-- prevent our request from triggering chat messages on login
	for index = 1, Constants.ChatFrameConstants.MaxChatWindows do
		if _G['ChatFrame' .. index]:IsEventRegistered('TIME_PLAYED_MSG') then
			_G['ChatFrame' .. index]:UnregisterEvent('TIME_PLAYED_MSG')
		end
	end

	RequestTimePlayed() -- triggers TIME_PLAYED_MSG
end

function addon:TIME_PLAYED_MSG(total)
	if not InomenaPlayed then
		InomenaPlayed = {}
	end

	InomenaPlayed[playerIdentifier] = total

	for index = 1, Constants.ChatFrameConstants.MaxChatWindows do
		for _, group in next, _G['ChatFrame' .. index].messageTypeList do
			if group == 'SYSTEM' then
				_G['ChatFrame' .. index]:RegisterEvent('TIME_PLAYED_MSG')
				break
			end
		end
	end
end

function addon:OnLogout()
	-- update stored play time on session end
	local played = InomenaPlayed[playerIdentifier]
	InomenaPlayed[playerIdentifier] = played + (sessionStart - GetTime())
end

local function formatAverage(total)
	-- calculate the average value since the servers opened
	return AVG_VALUE:format(total / (GetServerTime() - LAUNCH_DATE) * 24)
end

hooksecurefunc(ChatFrameUtil, 'DisplayTimePlayed', function(chatFrame)
	-- tally up total play time across all characters
	local total = 0
	for _, seconds in next, InomenaPlayed do
		total = total + seconds
	end

	-- format tally in a human readable way
	local d, h, m, s = ChatFrameUtil.TimeBreakDown(total)
	local time = TIME_DAYHOURMINUTESECOND:format(d, h, m, s)

	-- display extra columns with the other lines this method renders
	local info = ChatTypeInfo.SYSTEM
	chatFrame:AddMessage('Account time played: ' .. time, info.r, info.g, info.b, info.id)
	chatFrame:AddMessage('Average time played since launch: ' .. formatAverage(total), info.r, info.g, info.b, info.id)
end)
