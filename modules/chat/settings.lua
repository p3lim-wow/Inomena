local _, addon = ...

local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 10 -- FrameXML/ChatFrame.lua
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME -- FrameXML/ChatFrame.lua

local function createChatFrame(name, ...)
	local chatFrame = name and FCF_OpenNewWindow(name, true) or DEFAULT_CHAT_FRAME

	-- wipe all default channels
	ChatFrame_RemoveAllMessageGroups(chatFrame)
	ChatFrame_RemoveAllChannels(chatFrame)
	ChatFrame_ReceiveAllPrivateMessages(chatFrame)

	-- change color and alpha
	FCF_SetWindowColor(chatFrame, 0, 0, 0)
	FCF_SetWindowAlpha(chatFrame, 0)

	-- register custom channels
	if ... then
		for index = 1, select('#', ...) do
			ChatFrame_AddMessageGroup(chatFrame, select(index, ...))
		end
	end

	return chatFrame
end

local function setupChatFrames()
	-- clear out existing setup so we have a predictable base
	FCF_ResetChatWindows()

	-- close every chat frame
	for index = 2, NUM_CHAT_WINDOWS do
		FCF_Close(_G['ChatFrame' .. index])
	end

	-- create new chat frames with our prefered channels
	createChatFrame(nil, 'SYSTEM', 'SAY', 'EMOTE', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER', 'GUILD', 'OFFICER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT')
	createChatFrame('Whisper', 'WHISPER', 'BN_WHISPER', 'IGNORED')
	createChatFrame('Loot', 'LOOT', 'CURRENCY', 'MONEY', 'SKILL', 'COMBAT_FACTION_CHANGE')
	ChatFrame_AddChannel(createChatFrame('Channels'), 'General')

	-- select the default chat frame
	FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)

	-- set colors
	ChangeChatColor('OFFICER', 3/4, 1/2, 1/2)
	ChangeChatColor('RAID', 0, 1, 4/5)
	ChangeChatColor('RAID_LEADER', 0, 1, 4/5)
	ChangeChatColor('RAID_WARNING', 1, 1/4, 1/4)
	ChangeChatColor('BATTLEGROUND_LEADER', 1, 1/2, 0)
	ChangeChatColor('PARTY_LEADER', 2/3, 2/3, 1)
	ChangeChatColor('BN_WHISPER', 1, 1/2, 1)
	ChangeChatColor('BN_WHISPER_INFORM', 1, 1/2, 1)
	ChangeChatColor('INSTANCE_CHAT_LEADER', 1, 1/2, 0)

	-- reload edit mode layout
	local layoutInfo = C_EditMode.GetLayouts()
	C_EditMode.SetActiveLayout(1) -- set one of the base layouts first
	C_EditMode.SetActiveLayout(layoutInfo.activeLayout)

	addon:Print('Chat frames reset, everything is tainted, you should /reload')
end

-- add a quick slash to reset in case something is wrong
addon:RegisterSlash('/chatreset', setupChatFrames)

function addon:PLAYER_LOGIN()
	-- prevent stickyness
	ChatTypeInfo.CHANNEL.sticky = 0
	ChatTypeInfo.WHISPER.sticky = 0
	ChatTypeInfo.BN_WHISPER.sticky = 0

	-- make more channels flash
	ChatTypeInfo.GUILD.flashTab = true
	ChatTypeInfo.OFFICER.flashTab = true

	-- we'll never have channels in the default window, use that as an indicator for when to reset
	if #DEFAULT_CHAT_FRAME.channelList > 0 then
		setupChatFrames()
	end
end

-- force enable class colors in chat
function addon:UPDATE_CHAT_COLOR_NAME_BY_CLASS(chatType, shouldColor)
	if not shouldColor then
		SetChatColorNameByClass(chatType, true)
	end
end
