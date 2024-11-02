local _, addon = ...

local CHAT_FRAMES = {
	'General',
	'Whisper',
	'Loot',
	'Channels',
}

local CHAT_GROUPS = {
	{
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
	},
	{
		'WHISPER',
		'BN_WHISPER',
		'IGNORED'
	},
	{
		'LOOT',
		'CURRENCY',
		'MONEY',
		'SKILL',
		'COMBAT_FACTION_CHANGE'
	},
}

local CHAT_CHANNELS = {
	[4] = {
		'General'
	},
}

local function createChatFrame(index, name)
	local chatFrame
	if index == 1 then
		chatFrame = DEFAULT_CHAT_FRAME
	else
		chatFrame = FCF_OpenNewWindow(name, true)
	end

	-- change color and alpha
	FCF_SetWindowColor(chatFrame, 0, 0, 0)
	FCF_SetWindowAlpha(chatFrame, 0)

	return chatFrame
end

local function registerChannels(chatFrame, tabIndex)
	-- wipe all default channels
	ChatFrame_RemoveAllMessageGroups(chatFrame)
	ChatFrame_RemoveAllChannels(chatFrame)
	ChatFrame_ReceiveAllPrivateMessages(chatFrame)

	if CHAT_GROUPS[tabIndex] then
		for _, group in next, CHAT_GROUPS[tabIndex] do
			ChatFrame_AddMessageGroup(chatFrame, group)
		end
	end

	if CHAT_CHANNELS[tabIndex] then
		for _, channel in next, CHAT_CHANNELS[tabIndex] do
			ChatFrame_AddChannel(chatFrame, channel)
		end
	end
end

local function setupChatFrames(tabIndex)
	-- clear out existing setup so we have a predictable base
	FCF_ResetChatWindows()

	-- close every chat frame
	for index = 2, NUM_CHAT_WINDOWS do
		FCF_Close(_G['ChatFrame' .. index])
	end

	for tabIndex, name in next, CHAT_FRAMES do
		local chatFrame = createChatFrame(tabIndex, name)
		registerChannels(chatFrame, tabIndex)
	end

	-- select the default chat frame
	FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)

	-- reload edit mode layout
	if addon:IsRetail() then
		local layoutInfo = C_EditMode.GetLayouts()
		C_EditMode.SetActiveLayout(1) -- set one of the base layouts first
		C_EditMode.SetActiveLayout(layoutInfo.activeLayout)
	else
		-- TODO: position (bottomleft, 32, 32), size (500x246)
	end

	addon:Print('Chat frames reset, everything is tainted, you should /reload')
end

-- add a quick slash to reset in case something is wrong
addon:RegisterSlash('/chatreset', setupChatFrames)

function addon:PLAYER_ENTERING_WORLD(initialLogin)
	local tabIndex = 1
	for chatFrameIndex = 1, NUM_CHAT_WINDOWS do
		local frame = _G['ChatFrame' .. chatFrameIndex]

		if chatFrameIndex == 2 or chatFrameIndex == 3 then
			-- these two frames are reserved for "Combat Log" and "Voice",
			-- and we need to ignore them
		else
			local name, _, _, _, _, _, _, _, docked = FCF_GetChatWindowInfo(chatFrameIndex)
			if docked and name ~= CHAT_FRAMES[tabIndex] then
				-- we have a chatframe that differs from our presets, let's reset and set up
				setupChatFrames(tabIndex)
				return -- no point checking more frames
			end

			tabIndex = tabIndex + 1
		end
	end

	if initialLogin then
		-- BUG: currently the channels aren't staying between logins, so we need to set up groups
		--      and channels on every login, hopefully without any taints
		tabIndex = 1
		for chatFrameIndex = 1, NUM_CHAT_WINDOWS do
			if chatFrameIndex == 2 or chatFrameIndex == 3 then
				-- ignore
			else
				local name, _, _, _, _, _, _, _, docked = FCF_GetChatWindowInfo(chatFrameIndex)
				if docked and name == CHAT_FRAMES[tabIndex] then
					-- TODO: this doesn't seem to work?
					registerChannels(_G['ChatFrame' .. chatFrameIndex], tabIndex)
				end

				tabIndex = tabIndex + 1
			end
		end
	end
end
