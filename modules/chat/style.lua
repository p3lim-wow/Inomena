local _, addon = ...

local function onMouseWheel(chatFrame, direction)
	if direction > 0 then
		if IsShiftKeyDown() then
			chatFrame:ScrollToTop()
		elseif IsControlKeyDown() then
			chatFrame:PageUp()
		else
			chatFrame:ScrollUp()
		end
	else
		if IsShiftKeyDown() then
			chatFrame:ScrollToBottom()
		elseif IsControlKeyDown() then
			chatFrame:PageDown()
		else
			chatFrame:ScrollDown()
		end
	end
end

local function updateChatTab(chatTab)
	if chatTab:GetObjectType() ~= 'Button' then
		-- one of the FCF hooks triggered this, we need to get the tab
		chatTab = _G[chatTab:GetName() .. 'Tab']
	end

	if chatTab:IsMouseOver() then
		chatTab.Text:SetTextColor(0, 0.6, 1)
	elseif chatTab.alerting then
		-- set by FCF
		chatTab.Text:SetTextColor(1, 0, 0)
	elseif chatTab:GetID() == SELECTED_CHAT_FRAME:GetID() then
		chatTab.Text:SetTextColor(1, 1, 1)
	else
		chatTab.Text:SetTextColor(1/2, 1/2, 1/2)
	end
end

local function updateChatFrame(chatFrame)
	chatFrame:SetClampRectInsets(0, 0, 0, 0)
	chatFrame:SetSpacing(1.4)
	chatFrame:SetScript('OnMouseWheel', onMouseWheel)

	addon:Hide(chatFrame.ScrollBar)

	local editBox = chatFrame.editBox
	editBox:ClearAllPoints()
	editBox:SetPoint('TOPRIGHT', chatFrame, 'BOTTOMRIGHT')
	editBox:SetPoint('TOPLEFT', chatFrame, 'BOTTOMLEFT')
	editBox:SetHeight(20)
	editBox:SetFontObject(addon.FONT)
	editBox:SetAltArrowKeyMode(false)

	for _, child in next, {editBox:GetRegions()} do
		if child:GetObjectType() == 'Texture' and child:GetName() then
			-- the cursor is a texture object, but it doesn't have a name
			addon:Hide(child)
		end
	end

	local editBoxHeader = editBox.header
	editBoxHeader:ClearAllPoints()
	editBoxHeader:SetPoint('LEFT')
	editBoxHeader:SetFontObject(addon.FONT)

	local chatTab = _G[chatFrame:GetName() .. 'Tab']
	chatTab:RegisterForClicks('LeftButtonUp', 'RightButtonUp') -- disable middle click
	chatTab:SetScript('OnDragStart', nil) -- disable dragging windows
	chatTab:HookScript('OnEnter', updateChatTab)
	chatTab:HookScript('OnLeave', updateChatTab)

	local font, size, flags = _G[addon.FONT]:GetFont()
	chatTab.Text:SetFont(font, size, flags)
	chatTab.Text:SetShadowOffset(0, 0)

	for _, child in next, {chatTab:GetRegions()} do
		if child:GetObjectType() == 'Texture' then
			child:SetTexture(nil)
		end
	end
end

local function createChatFrame(name, ...)
	local chatFrame = name and FCF_OpenNewWindow(name, true) or ChatFrame1
	ChatFrame_RemoveAllMessageGroups(chatFrame)
	ChatFrame_RemoveAllChannels(chatFrame)
	ChatFrame_ReceiveAllPrivateMessages(chatFrame)

	FCF_SetWindowColor(chatFrame, 0, 0, 0)
	FCF_SetWindowAlpha(chatFrame, 0)

	if ... then
		-- add every message group passed through
		for index = 1, select('#', ...) do
			ChatFrame_AddMessageGroup(chatFrame, select(index, ...))
		end
	end

	return chatFrame
end

local function createChatFrames()
	-- clear out existing setup
	FCF_ResetChatWindows()

	for index = 2, NUM_CHAT_WINDOWS do
		-- just to make sure, there might be pet battle windows or w/e remaining
		FCF_Close(_G['ChatFrame' .. index])
	end

	-- create new frames
	local window = createChatFrame(nil, 'SYSTEM', 'SAY', 'EMOTE', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER', 'GUILD', 'OFFICER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT')
	createChatFrame('Combat') -- we'll hide this later
	createChatFrame('Whisper', 'WHISPER', 'BN_WHISPER', 'IGNORED')
	createChatFrame('Loot', 'LOOT', 'CURRENCY', 'MONEY', 'SKILL', 'COMBAT_FACTION_CHANGE')

	local channelFrame = createChatFrame('Channels')
	ChatFrame_AddChannel(channelFrame, 'General')

	-- reposition
	window:ClearAllPoints()
	window:SetPoint('BOTTOMLEFT', UIParent, 50, 50)
	window:SetSize(400, 180)
	FCF_SavePositionAndDimensions(window)
	FCF_RestorePositionAndDimensions(window) -- the above position doesn't take effect

	-- hide the combat frame
	FCF_Close(ChatFrame2)

	-- select the default chat frame
	FCF_SelectDockFrame(window)

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
end

function addon:UPDATE_CHAT_WINDOWS()
	local font, size, flags = _G[addon.FONT]:GetFont()
	for index = 1, NUM_CHAT_WINDOWS do
		local chatFrame = _G['ChatFrame' .. index]
		chatFrame:SetFont(font, size, flags)
		chatFrame:SetShadowOffset(0, 0)
	end
end

function addon:PLAYER_LOGIN()
	-- no hover background changes
	_G.DEFAULT_CHATFRAME_ALPHA = 0

	-- adjust tab alpha changes
	_G.CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	_G.CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	_G.CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.7

	-- adjust animation times
	_G.CHAT_TAB_SHOW_DELAY = 0
	_G.CHAT_TAB_HIDE_DELAY = 0.5
	_G.CHAT_FRAME_FADE_TIME = 0
	_G.CHAT_FRAME_FADE_OUT_TIME = 0.5

	-- create frames if they don't exist already
	if FCF_GetChatWindowInfo(4) == '' then
		createChatFrames()
	end

	-- skin chatframes
	for index = 1, NUM_CHAT_WINDOWS do
		updateChatFrame(_G['ChatFrame' .. index])
	end

	-- hook into functions that would reset chat tab colors
	hooksecurefunc('FCFTab_UpdateColors', updateChatTab)
	hooksecurefunc('FCF_StartAlertFlash', updateChatTab)

	-- change stickyness of the chat edit box
	ChatTypeInfo.CHANNEL.sticky = 0
	ChatTypeInfo.WHISPER.sticky = 0
	ChatTypeInfo.BN_WHISPER.sticky = 0

	-- make some channels flash
	ChatTypeInfo.GUILD.flashTab = true
	ChatTypeInfo.OFFICER.flashTab = true

	-- remove some buttons
	addon:Hide(QuickJoinToastButton)
	addon:Hide(ChatFrameChannelButton)
	addon:Hide(ChatFrameMenuButton)

	for index = 1, NUM_CHAT_WINDOWS do
		addon:Hide('ChatFrame' .. index .. 'ButtonFrame')
	end
end

function addon:PLAYER_ENTERING_WORLD()
	-- game keeps re-adding the fucking channels to chatframe 1
	ChatFrame_RemoveAllChannels(ChatFrame1)
end

function addon:UPDATE_CHAT_COLOR_NAME_BY_CLASS(chatType, shouldColor)
	-- force enable class colors in chat
	if not shouldColor then
		SetChatColorNameByClass(chatType, true)
	end
end

hooksecurefunc('ChatEdit_UpdateHeader', function(editBox)
	-- fix inset of chat edit header
	editBox:SetTextInsets(editBox.header:GetWidth(), 0, 0, 0)
end)
