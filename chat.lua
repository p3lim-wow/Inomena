local _, Inomena = ...

local function CreateChat(index, name, ...)
	local frame
	if(index == 1) then
		frame = ChatFrame1
	else
		frame = FCF_OpenNewWindow(name)
	end

	ChatFrame_RemoveAllMessageGroups(frame)
	ChatFrame_RemoveAllChannels(frame)

	if(...) then
		for index = 1, select('#', ...) do
			ChatFrame_AddMessageGroup(frame, select(index, ...))
		end
	end

	return frame
end

function Inomena.Initialize.CHAT()
	CreateChat(1, 'General', 'SAY', 'EMOTE', 'GUILD', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'BATTLEGROUND', 'BATTLEGROUND_LEADER', 'SYSTEM', 'MONSTER_WHISPER', 'MONSTER_BOSS_WHISPER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT')
	FCF_Close(ChatFrame2)
	CreateChat(2, 'Whisper', 'BN_WHISPER', 'WHISPER', 'IGNORED')
	CreateChat(3, 'Loot', 'LOOT')

	local channels = CreateChat(4, 'Channels')
	ChatFrame_AddChannel(channels, 'General')
	ChatFrame_AddChannel(channels, 'Trade')
	ChatFrame_AddChannel(channels, 'LookingForGroup')

	SetChatWindowAlpha(1, 0)
	SetChatWindowSavedPosition(1, 'BOTTOMLEFT', 0.003, 0.025)
	SetChatWindowSavedDimensions(1, 400, 100)

	ToggleChatColorNamesByClassGroup(true, 'SAY')
	ToggleChatColorNamesByClassGroup(true, 'EMOTE')
	ToggleChatColorNamesByClassGroup(true, 'GUILD')
	ToggleChatColorNamesByClassGroup(true, 'WHISPER')
	ToggleChatColorNamesByClassGroup(true, 'PARTY')
	ToggleChatColorNamesByClassGroup(true, 'PARTY_LEADER')
	ToggleChatColorNamesByClassGroup(true, 'RAID')
	ToggleChatColorNamesByClassGroup(true, 'RAID_LEADER')
	ToggleChatColorNamesByClassGroup(true, 'RAID_WARNING')
	ToggleChatColorNamesByClassGroup(true, 'BATTLEGROUND')
	ToggleChatColorNamesByClassGroup(true, 'BATTLEGROUND_LEADER')
	ToggleChatColorNamesByClassGroup(true, 'ACHIEVEMENT')
	ToggleChatColorNamesByClassGroup(true, 'GUILD_ACHIEVEMENT')
	ToggleChatColorNamesByClassGroup(true, 'CHANNEL1')
	ToggleChatColorNamesByClassGroup(true, 'CHANNEL2')
	ToggleChatColorNamesByClassGroup(true, 'CHANNEL3')

	ChangeChatColor('RAID_LEADER', 1, 127/255, 0)
	ChangeChatColor('RAID_WARNING', 1, 1/4, 1/4)
	ChangeChatColor('BATTLEGROUND_LEADER', 1, 127/255, 0)
	ChangeChatColor('PARTY_LEADER', 2/3, 2/3, 1)
end
