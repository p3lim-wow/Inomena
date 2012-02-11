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
	CreateChat(1, 'General', 'SAY', 'EMOTE', 'GUILD', 'OFFICER', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'BATTLEGROUND', 'BATTLEGROUND_LEADER', 'SYSTEM', 'MONSTER_WHISPER', 'MONSTER_BOSS_WHISPER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT')
	FCF_Close(ChatFrame2)
	CreateChat(2, 'Whisper', 'BN_WHISPER', 'WHISPER', 'IGNORED')
	CreateChat(3, 'Loot', 'LOOT', 'COMBAT_FACTION_CHANGE')

	local channels = CreateChat(4, 'Channels')
	ChatFrame_AddChannel(channels, 'General')
	ChatFrame_AddChannel(channels, 'Trade')

	SetChatWindowAlpha(1, 0)
	SetChatWindowSavedPosition(1, 'BOTTOMLEFT', 0.003, 0.025)
	SetChatWindowSavedDimensions(1, 400, 100)

	ChangeChatColor('OFFICER', 3/4, 1/2, 1/2)
	ChangeChatColor('RAID', 0, 1, 4/5)
	ChangeChatColor('RAID_LEADER', 0, 1, 4/5)
	ChangeChatColor('RAID_WARNING', 1, 1/4, 1/4)
	ChangeChatColor('BATTLEGROUND_LEADER', 1, 1/2, 0)
	ChangeChatColor('PARTY_LEADER', 2/3, 2/3, 1)
	ChangeChatColor('BN_WHISPER', 1, 1/2, 1)
	ChangeChatColor('BN_WHISPER_INFORM', 1, 1/2, 1)
end

Inomena.RegisterEvent('UPDATE_CHAT_COLOR_NAME_BY_CLASS', function(type, enabled)
	if(not enabled) then
		SetChatColorNameByClass(type, true)
	end
end)
