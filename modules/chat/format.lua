local _, addon = ...

local ABBREVIATIONS = {
	OFFICER = 'o',
	GUILD = 'g',
	PARTY = 'p',
	RAID = 'r',
	INSTANCE_CHAT = 'i',
}

local CLIENT_COLORS = {
	[BNET_CLIENT_APP] = '22aaff',
	[BNET_CLIENT_WOW] = '5cc400',
}

local function getClientColorAndTag(accountID)
	local account = C_BattleNet.GetAccountInfoByID(accountID)
	local accountClient = account.gameAccountInfo.clientProgram
	local color = CLIENT_COLORS[accountClient] or CLIENT_COLORS[BNET_CLIENT_APP]
	return color, account.battleTag:match('(%w+)#%d+')
end

local FORMAT_PLAYER = '|Hplayer:%s|h%s|h'
local function formatPlayer(info, name)
	return FORMAT_PLAYER:format(info, name:gsub('%-[^|]+', ''))
end

local FORMAT_BN_PLAYER = '|HBNplayer:%s|h|cff%s%s|r|h'
local function formatBNPlayer(info)
	-- replace the colors with a client color
	local color, tag = getClientColorAndTag(info:match('(%d+):'))
	return FORMAT_BN_PLAYER:format(info, color, tag)
end

local FORMAT_CHANNEL = '|Hchannel:%s|h%s|h %s'
local function formatChannel(info, name)
	if name:match(LEADER) then
		return FORMAT_CHANNEL:format(info, ABBREVIATIONS[info] or info:gsub('channel:', ''), '|cffffff00!|r')
	else
		return FORMAT_CHANNEL:format(info, ABBREVIATIONS[info] or info:gsub('channel:', ''), '')
	end
end

local FORMAT_WAYPOINT_FAR = '|Hworldmap:%d:%d:%d|h[%s: %.2f, %.2f]|h'
local FORMAT_WAYPOINT_NEAR = '|Hworldmap:%d:%d:%d|h[%.2f, %.2f]|h'
local function formatWaypoint(mapID, x, y)
	local playerMapID = C_Map.GetBestMapForUnit('player')
	if tonumber(mapID) ~= playerMapID then
		local mapInfo = C_Map.GetMapInfo(mapID)
		return FORMAT_WAYPOINT_FAR:format(mapID, x, y, mapInfo.name, x / 100, y / 100)
	else
		return FORMAT_WAYPOINT_NEAR:format(mapID, x, y, x / 100, y / 100)
	end
end

local chatFrameHooks = {}
local function addMessage(chatFrame, msg, ...)
	msg = msg:gsub('|Hplayer:(.-)|h%[(.-)%]|h', formatPlayer)
	msg = msg:gsub('|HBNplayer:(.-)|h%[(.-)%]|h', formatBNPlayer)
	msg = msg:gsub('|Hchannel:(.-)|h%[(.-)%]|h', formatChannel)
	msg = msg:gsub('^%w- (|H)', '|cffa1a1a1@|r%1')
	msg = msg:gsub('^(.-|h) %w-:', '%1:')
	msg = msg:gsub('^%[' .. RAID_WARNING .. '%]', 'w')
	msg = msg:gsub('|Hworldmap:(.-):(.-):(.-)|h%[(.-)%]|h', formatWaypoint)
	msg = msg:gsub(CHAT_FLAG_AFK, '')
	msg = msg:gsub(CHAT_FLAG_DND, '')

	return chatFrameHooks[chatFrame](chatFrame, msg, ...)
end

for index = 1, NUM_CHAT_WINDOWS do
	if index ~= 2 then -- ignore combat frame
		-- override the message injection
		local chatFrame = _G['ChatFrame' .. index]
		chatFrameHooks[chatFrame] = chatFrame.AddMessage
		chatFrame.AddMessage = addMessage
	end
end
