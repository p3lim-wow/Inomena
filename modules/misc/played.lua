local _, addon = ...

local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 10 -- FrameXML/ChatFrame.lua
local TIME_DAYHOURMINUTESECOND = _G.TIME_DAYHOURMINUTESECOND -- globalstring

local registered = {}
function addon:PLAYER_LOGIN()
	-- unregister events
	for index = 1, NUM_CHAT_WINDOWS do
		if _G['ChatFrame' .. index]:IsEventRegistered('TIME_PLAYED_MSG') then
			_G['ChatFrame' .. index]:UnregisterEvent('TIME_PLAYED_MSG')
			table.insert(registered, index)
		end
	end

	RequestTimePlayed()
end

local sessionStart, playerRealm, playerName
function addon:TIME_PLAYED_MSG(total)
	if not _G.InomenaPlayed then
		_G.InomenaPlayed = {}
	end

	playerRealm = GetRealmID()
	if not _G.InomenaPlayed[playerRealm] then
		_G.InomenaPlayed[playerRealm] = {}
	end

	playerName = UnitName('player') .. ':' .. (UnitClassBase('player'))
	_G.InomenaPlayed[playerRealm][playerName] = total

	if registered then
		sessionStart = GetTime()

		-- restore events
		for _, index in next, registered do
			_G['ChatFrame' .. index]:RegisterEvent('TIME_PLAYED_MSG')
		end

		registered = nil
	end
end

local AVG_VALUE = '%.2f hours/day'
local function formatAverage(total)
	return AVG_VALUE:format(total / (GetServerTime() - 1108080000) * 24)
end

hooksecurefunc('ChatFrame_DisplayTimePlayed', function(self)
	local total = 0
	for _, characters in next, _G.InomenaPlayed do
		for _, seconds in next, characters do
			total = total + seconds
		end
	end

	local d, h, m, s = ChatFrame_TimeBreakDown(total)
	local time = TIME_DAYHOURMINUTESECOND:format(d, h, m, s)
	local info = ChatTypeInfo.SYSTEM
	self:AddMessage('Account time played: ' .. time, info.r, info.g, info.b, info.id)
	self:AddMessage('Average time played since launch: ' .. formatAverage(total), info.r, info.g, info.b, info.id)
end)

function addon:PLAYER_LOGOUT()
	_G.InomenaPlayed[playerRealm][playerName] = _G.InomenaPlayed[playerRealm][playerName] + (sessionStart - GetTime())
end
