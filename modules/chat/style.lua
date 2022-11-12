local _, addon = ...

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

	-- skin chatframes
	for index = 1, NUM_CHAT_WINDOWS do
		updateChatFrame(_G['ChatFrame' .. index])
	end

	-- hook into functions that would reset chat tab colors
	hooksecurefunc('FCFTab_UpdateColors', updateChatTab)
	hooksecurefunc('FCF_StartAlertFlash', updateChatTab)
end
