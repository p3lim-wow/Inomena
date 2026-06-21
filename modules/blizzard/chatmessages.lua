local _, addon = ...

-- format chat messages

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
	if account then -- fails when bnet is offline
		local accountClient = account.gameAccountInfo.clientProgram
		local color = CLIENT_COLORS[accountClient] or CLIENT_COLORS[BNET_CLIENT_APP]
		return color, account.battleTag:match('(%w+)#%d+')
	end
end

local FORMAT_BN_PLAYER = '|HBNplayer:%s|h|cff%s%s|r|h'
local function formatBNPlayer(info)
	local color, tag = getClientColorAndTag(info:match('(%d+):'))
	return FORMAT_BN_PLAYER:format(info, color or 'ffffff', tag or UNKNOWN)
end

local FORMAT_PLAYER = '|Hplayer:%s|h%s|h'
local function formatPlayer(info, name)
	return FORMAT_PLAYER:format(info, (name:gsub('%-[^|]+', '')))
end

local FORMAT_CHANNEL = '|Hchannel:%s|h%s|h %s'
local function formatChannel(info, name)
	if name:match(LEADER) then
		return FORMAT_CHANNEL:format(info, ABBREVIATIONS[info] or info:gsub('channel:', ''), '|cffffff00!|r')
	else
		return FORMAT_CHANNEL:format(info, ABBREVIATIONS[info] or info:gsub('channel:', ''), '')
	end
end

-- format waypoint links to include map name and coordinates
local FORMAT_WAYPOINT_FAR = '|Hworldmap:%d:%d:%d|h[%s: %.2f, %.2f]|h'
local FORMAT_WAYPOINT_NEAR = '|Hworldmap:%d:%d:%d|h[%.2f, %.2f]|h'
local function formatWaypoint(mapID, x, y)
	local playerMapID = addon:GetPlayerMapID()
	if tonumber(mapID) ~= playerMapID then
		local mapInfo = C_Map.GetMapInfo(mapID)
		return FORMAT_WAYPOINT_FAR:format(mapID, x, y, mapInfo.name, x / 100, y / 100)
	else
		return FORMAT_WAYPOINT_NEAR:format(mapID, x, y, x / 100, y / 100)
	end
end

local function manipulateBuffer(_, element)
	local msg = element and element.message
	if not msg or issecretvalue(msg) then
		return
	end

	msg = msg:gsub('|Hplayer:(.-)|h%[(.-)%]|h', formatPlayer)
	msg = msg:gsub('|HBNplayer:(.-)|h%[(.-)%]|h', formatBNPlayer)
	msg = msg:gsub('|Hchannel:(.-)|h%[(.-)%]|h', formatChannel)
	msg = msg:gsub('^%w- (|H)', '|cffa1a1a1@|r%1')
	msg = msg:gsub('^(.-|h) %w-:', '%1:') -- replace channel name with number only
	msg = msg:gsub('^%[' .. RAID_WARNING .. '%]', 'w')
	msg = msg:gsub('|Hworldmap:(.-):(.-):(.-)|h%[(.-)%]|h', formatWaypoint)

	-- remove extra info
	msg = msg:gsub('|cff.-' .. NPEV2_CHAT_GUIDE_FRAME_TITLE_STOP_GUIDING .. '|r ', '')
	msg = msg:gsub(CHAT_FLAG_AFK, '')
	msg = msg:gsub(CHAT_FLAG_DND, '')
	msg = msg:gsub(' |A:friendslist%-recentallies%-yellow:11:11:0:0|a', '')

	-- replace message
	element.message = msg
end

function addon:OnLogin()
	for index = 1, Constants.ChatFrameConstants.MaxChatWindows do
		if index ~= 2 and index ~= 3 then -- ignore combat log and voice log
			-- hook when the buffer gets a new element pushed to it
			hooksecurefunc(_G['ChatFrame' .. index].historyBuffer, 'PushFront', manipulateBuffer)
		end
	end
end
