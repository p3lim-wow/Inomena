local E, F, C = unpack(select(2, ...))

local gsub = string.gsub
local match = string.match
local format = string.format

local shorthands = {
	INSTANCE_CHAT = 'i',
	OFFICER = 'o',
	GUILD = 'g',
	PARTY = 'p',
	RAID = 'r'
}

local classes = {}
for token, localized in next, LOCALIZED_CLASS_NAMES_MALE do
	classes[localized] = token
end

for token, localized in next, LOCALIZED_CLASS_NAMES_FEMALE do
	classes[localized] = token
end

local function AbbreviateChannel(channel, name)
	local flag = ''
	if(match(name, LEADER)) then
		flag = '|cffffff00!|r'
	end

	return format('|Hchannel:%s|h%s|h %s', channel, shorthands[channel] or gsub(channel, 'channel:', ''), flag)
end

local function FormatPlayer(info, name)
	return format('|Hplayer:%s|h%s|h', info, gsub(name, '%-[^|]+', ''))
end

local function FormatBNPlayer(info)
	local _, _, battleTag, _, _, _, client = BNGetFriendInfoByID(match(info, '(%d+):'))
	local color = C.ClientColors[client] or '22aaff'
	return format('|HBNplayer:%s|h|cff%s%s|r|h', info, color, match(battleTag, '(%w+)#%d+'))
end

local hooks = {}
local function AddMessage(self, message, ...)
	message = gsub(message, '|Hplayer:(.-)|h%[(.-)%]|h', FormatPlayer)
	message = gsub(message, '|HBNplayer:(.-)|h%[(.-)%]|h', FormatBNPlayer)
	message = gsub(message, '|Hchannel:(.-)|h%[(.-)%]|h ', AbbreviateChannel)

	message = gsub(message, '^%w- (|H)', '|cffa1a1a1@|r%1')
	message = gsub(message, '^(.-|h) %w-:', '%1:')
	message = gsub(message, '^%[' .. RAID_WARNING .. '%]', 'w')

	return hooks[self](self, message, ...)
end

for index = 1, 5 do
	if(index ~= 2) then
		local ChatFrame = _G['ChatFrame' .. index]
		hooks[ChatFrame] = ChatFrame.AddMessage
		ChatFrame.AddMessage = AddMessage
	end
end
