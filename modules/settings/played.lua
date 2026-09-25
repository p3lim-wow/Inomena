local _, addon = ...

-- track account-wide played time (because I hate myself)

local AVG_VALUE = '%.2f hours/day'
local LAUNCH_EU = 1108080000 -- Febrary 11th 2005

local sessionStart, playerIdentifier
local chatFrameEvents = addon:T()
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
			chatFrameEvents:insert(_G['ChatFrame' .. index])
		end
	end

	RequestTimePlayed() -- triggers TIME_PLAYED_MSG
end

function addon:TIME_PLAYED_MSG(total)
	if not InomenaPlayed2 then
		InomenaPlayed2 = {}
	end

	if InomenaPlayed and addon:IsRetail() then
		for realm, chars in next, InomenaPlayed do
			for char, seconds in next, chars do
				InomenaPlayed2[realm .. '-' .. char] = seconds
			end
		end

		InomenaPlayed = nil
	end

	InomenaPlayed2[playerIdentifier] = total

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
	local played = InomenaPlayed2[playerIdentifier]
	InomenaPlayed2[playerIdentifier] = played + (sessionStart - GetTime())
end

local function formatAverage(total)
	-- calculate the average value since the servers opened in 2005
	return AVG_VALUE:format(total / (GetServerTime() - LAUNCH_EU) * 24)
end

hooksecurefunc(ChatFrameUtil, 'DisplayTimePlayed', function(chatFrame)
	-- tally up total play time across all characters
	local total = 0
	for _, seconds in next, InomenaPlayed2 do
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
