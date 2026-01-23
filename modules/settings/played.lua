local _, addon = ...

-- track account-wide played time (because I hate myself)

local AVG_VALUE = '%.2f hours/day'
local LAUNCH_EU = 1108080000 -- Febrary 11th 2005

local sessionStart, playerNameClass
local chatFrameEvents = addon:T()
function addon:OnLogin()
	sessionStart = GetTime()
	playerNameClass = UnitName('player') .. ':' .. addon.PLAYER_CLASS

	-- prevent our request from triggering chat messages on login
	for index = 1, NUM_CHAT_WINDOWS do
		if _G['ChatFrame' .. index]:IsEventRegistered('TIME_PLAYED_MSG') then
			_G['ChatFrame' .. index]:UnregisterEvent('TIME_PLAYED_MSG')
			chatFrameEvents:insert(_G['ChatFrame' .. index])
		end
	end

	RequestTimePlayed() -- triggers TIME_PLAYED_MSG
end

function addon:TIME_PLAYED_MSG(total)
	if not InomenaPlayed then
		InomenaPlayed = {}
	end

	if not InomenaPlayed[addon.PLAYER_REALM] then
		InomenaPlayed[addon.PLAYER_REALM] = {}
	end

	-- update stored play time with data from server
	InomenaPlayed[addon.PLAYER_REALM][playerNameClass] = total

	if chatFrameEvents then
		-- restore chat frame events
		for _, chatFrame in next, chatFrameEvents do
			chatFrame:RegisterEvent('TIME_PLAYED_MSG')
		end

		-- ensure we only do that once
		chatFrameEvents = nil
	end
end

function addon:OnLogout()
	-- update stored play time on session end
	local played = InomenaPlayed[addon.PLAYER_REALM][playerNameClass]
	InomenaPlayed[addon.PLAYER_REALM][playerNameClass] = played + (sessionStart - GetTime())
end

local function formatAverage(total)
	-- calculate the average value since the servers opened in 2005
	return AVG_VALUE:format(total / (GetServerTime() - LAUNCH_EU) * 24)
end

hooksecurefunc(ChatFrameUtil, 'DisplayTimePlayed', function(chatFrame)
	-- tally up total play time across all characters
	local total = 0
	for _, characters in next, InomenaPlayed do
		for _, seconds in next, characters do
			total = total + seconds
		end
	end

	-- format tally in a human readable way
	local d, h, m, s = ChatFrameUtil.TimeBreakDown(total)
	local time = TIME_DAYHOURMINUTESECOND:format(d, h, m, s)

	-- display extra columns with the other lines this method renders
	local info = ChatTypeInfo.SYSTEM
	chatFrame:AddMessage('Account time played: ' .. time, info.r, info.g, info.b, info.id)
	chatFrame:AddMessage('Average time played since launch: ' .. formatAverage(total), info.r, info.g, info.b, info.id)
end)
