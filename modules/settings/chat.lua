local _, addon = ...

local CHAT_FRAMES = {
	{
		name = 'General',
		groups = {
			'SYSTEM',
			'SAY',
			'EMOTE',
			'PARTY',
			'PARTY_LEADER',
			'RAID',
			'RAID_LEADER',
			'RAID_WARNING',
			'INSTANCE_CHAT',
			'INSTANCE_CHAT_LEADER',
			'GUILD',
			'OFFICER',
			'ACHIEVEMENT',
			'GUILD_ACHIEVEMENT',
			'MONSTER_SAY',
			'MONSTER_EMOTE',
			'MONSTER_YELL',
			'MONSTER_WHISPER',
			'MONSTER_BOSS_EMOTE',
			'MONSTER_BOSS_WHISPER',
		},
		channels = {
			'General',
			'NewcomerChat',
		},
	},
	{
		name = 'Whisper',
		groups = {
			'WHISPER',
			'BN_WHISPER',
			'IGNORED',
		},
	},
	{
		name = 'Loot',
		groups = {
			'LOOT',
			'CURRENCY',
			'MONEY',
			'SKILL',
			'COMBAT_FACTION_CHANGE',
		},
	},
}

local function setup(index, info)
	local chatFrame
	if index == 1 then
		chatFrame = DEFAULT_CHAT_FRAME
	else
		chatFrame = FCF_OpenNewWindow(info.name, true)
	end

	-- change color and alpha
	FCF_SetWindowColor(chatFrame, 0, 0, 0)
	FCF_SetWindowAlpha(chatFrame, 0)

	-- set font size
	FCF_SetChatWindowFontSize(nil, chatFrame, 14)

	-- remove the defaults
	chatFrame:RemoveAllMessageGroups()
	chatFrame:RemoveAllChannels()
	chatFrame:ReceiveAllPrivateMessages()

	-- set up our groups and channels
	if info.groups then
		for _, group in next, info.groups do
			chatFrame:AddMessageGroup(group)
		end
	end

	if info.channels then
		for _, channel in next, info.channels do
			chatFrame:AddChannel(channel)
		end
	end
end

local function reset()
	-- remove existing setup by resetting to default, which is predictable(-ish)
	FCF_ResetChatWindows()

	-- close all windows
	for index = 2, Constants.ChatFrameConstants.MaxChatWindows do
		FCF_Close(_G['ChatFrame' .. index])
	end

	-- register channels per frame
	for index, info in next, CHAT_FRAMES do
		setup(index, info)
	end

	-- select the default chat frame
	FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)

	-- TODO: reload edit mode layout (why?)
	-- TODO: print message (is it still tainty?)
	addon:Print('Chat frames reset, reloading is advised')
end

addon:RegisterSlash('/chatreset', reset)

function addon:OnLogin()
	local frameIndex = 1
	for chatIndex = 1, Constants.ChatFrameConstants.MaxChatWindows do
		if chatIndex ~= 2 and chatIndex ~= 3 then
			local name, _, _, _, _, _, _, _, isDocked = FCF_GetChatWindowInfo(chatIndex)
			if not isDocked or name ~= CHAT_FRAMES[frameIndex].name then
				reset()
				return -- we only loop to check for differences
			end

			-- ignore combat log and voice log
			frameIndex = frameIndex + 1
		end
	end
end
