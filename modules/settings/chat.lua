local E, F, C = unpack(select(2, ...))

local function Initialize()
	ChatFrame2:SetClampedToScreen(false)

	ChatTypeInfo.CHANNEL.sticky = 0
	ChatTypeInfo.WHISPER.sticky = 0
	ChatTypeInfo.BN_WHISPER.sticky = 0
	ChatTypeInfo.GUILD.flashTabOnGeneral = true
	ChatTypeInfo.OFFICER.flashTabOnGeneral = true
end

function E:PLAYER_LOGIN()
	if(InomenaSettings) then
		Initialize()
	end
end

local function CreateChatFrame(name, ...)
	local Frame = name and FCF_OpenNewWindow(name) or ChatFrame1
	ChatFrame_RemoveAllMessageGroups(Frame)
	ChatFrame_RemoveAllChannels(Frame)

	if(...) then
		for index = 1, select('#', ...) do
			ChatFrame_AddMessageGroup(Frame, select(index, ...))
		end
	end

	return Frame
end

table.insert(C.Settings, function()
	for index = 2, NUM_CHAT_WINDOWS do
		FCF_Close(_G['ChatFrame' .. index])
	end

	local parent = CreateChatFrame(nil, 'SAY', 'EMOTE', 'GUILD', 'OFFICER', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'BATTLEGROUND', 'BATTLEGROUND_LEADER', 'SYSTEM', 'MONSTER_WHISPER', 'MONSTER_BOSS_WHISPER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER')
	CreateChatFrame('Combat')
	CreateChatFrame('Whisper', 'BN_WHISPER', 'WHISPER', 'IGNORED')
	CreateChatFrame('Loot', 'LOOT', 'COMBAT_FACTION_CHANGE', 'CURRENCY', 'MONEY')

	local Frame = CreateChatFrame('Channels')
	ChatFrame_AddChannel(Frame, 'General')
	ChatFrame_AddChannel(Frame, 'Trade')

	parent:SetUserPlaced(true)
	parent:ClearAllPoints()
	parent:SetPoint('BOTTOMLEFT', UIParent, 35, 50)
	parent:SetSize(400, 100)

	FCF_SavePositionAndDimensions(parent)
	FCF_SetWindowAlpha(parent, 0)

	ChangeChatColor('OFFICER', 3/4, 1/2, 1/2)
	ChangeChatColor('RAID', 0, 1, 4/5)
	ChangeChatColor('RAID_LEADER', 0, 1, 4/5)
	ChangeChatColor('RAID_WARNING', 1, 1/4, 1/4)
	ChangeChatColor('BATTLEGROUND_LEADER', 1, 1/2, 0)
	ChangeChatColor('PARTY_LEADER', 2/3, 2/3, 1)
	ChangeChatColor('BN_WHISPER', 1, 1/2, 1)
	ChangeChatColor('BN_WHISPER_INFORM', 1, 1/2, 1)
	ChangeChatColor('INSTANCE_CHAT_LEADER', 1, 1/2, 0)

	FCF_SelectDockFrame(parent)
	FCF_Close(ChatFrame2)

	Initialize()
end)
