local _, addon = ...

-- style the chat frames

-- prevent stickyness in the edit box
ChatTypeInfo.CHANNEL.sticky = 0
ChatTypeInfo.WHISPER.sticky = 0
ChatTypeInfo.BN_WHISPER.sticky = 0

-- disable default flash tab logic
for chatType in next, ChatTypeInfo do
	ChatTypeInfo[chatType].flashTab = false
end

local function onChatScroll(chatFrame, direction)
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

-- custom handling for chat tab colors

local chatTabAlerts = {}
local chatTabIndices = addon:T()
local SetTextColor = UIParent:CreateFontString().SetTextColor -- get widget method
local function updateTabColor(tabIndex)
	local tab = _G['ChatFrame' .. tabIndex .. 'Tab']
	if chatTabAlerts[tabIndex] then
		SetTextColor(tab.Text, addon.colors.chatTab.alert:GetRGB())
	elseif tab:IsMouseOver() then
		SetTextColor(tab.Text, addon.colors.chatTab.hover:GetRGB())
	elseif tabIndex == SELECTED_CHAT_FRAME:GetID() then
		SetTextColor(tab.Text, addon.colors.chatTab.active:GetRGB())
	else
		SetTextColor(tab.Text, addon.colors.chatTab.inactive:GetRGB())
	end
end

local function onTabClick(chatTab)
	-- clear alert when selecting tab
	if chatTabAlerts[chatTab:GetID()] then
		chatTabAlerts[chatTab:GetID()] = false
	end

	-- update all tabs to ensure other tabs aren't colored as selected too
	for _, tabIndex in next, chatTabIndices do
		updateTabColor(tabIndex)
	end
end

for chatIndex = 1, NUM_CHAT_WINDOWS do
	if chatIndex ~= 2 and chatIndex ~= 3 then -- ignore combat log and voice log
		local chatFrame = _G['ChatFrame' .. chatIndex]
		local chatTab = _G['ChatFrame' .. chatIndex .. 'Tab']

		-- increase chat history
		chatFrame:SetMaxLines(10000)

		-- enable faster chat history scrolling
		chatFrame:SetScript('OnMouseWheel', onChatScroll)

		-- change chat font
		chatFrame:SetFont(addon.FONT, 13, 'OUTLINE')
		chatFrame:SetShadowOffset(0, 0)

		-- change chat tab font
		chatTab.Text:SetFont(addon.FONT, 12, 'OUTLINE')
		chatTab.Text:SetShadowOffset(0, 0)

		-- don't require holding alt key to navigate editbox
		chatFrame.editBox:SetAltArrowKeyMode(false)

		-- disable middle-click on tabs
		chatTab:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

		-- disable dragging tabs
		chatTab:RegisterForDrag()

		-- hook events for tabs
		chatTab:HookScript('OnEnter', GenerateClosure(updateTabColor, chatIndex))
		chatTab:HookScript('OnLeave', GenerateClosure(updateTabColor, chatIndex))
		chatTab:HookScript('PostClick', onTabClick)

		-- keep track of the tabs we modify, used in the PostClick handler to iterate over them
		chatTabIndices:insert(chatIndex)

		-- prevent Blizzard from coloring the tabs
		chatTab.Text.SetTextColor = nop

		-- update chat tab color
		updateTabColor(chatIndex)

		-- hide scroll bar and buttons
		addon:Hide(chatFrame, 'buttonFrame')
		addon:Hide(chatFrame, 'ScrollBar')

		-- hide all chat frame regions
		for _, region in next, {chatFrame:GetRegions()} do
			addon:Hide(region)
		end

		-- hide all chat tab textures
		for _, region in next, {chatTab:GetRegions()} do
			if region:GetObjectType() == 'Texture' then
				region:SetTexture(nil)
			end
		end
	end
end

-- change edit box font
ChatFrame1EditBox:SetFont(addon.FONT, 13, 'OUTLINE')
ChatFrame1EditBox:SetShadowOffset(0, 0)
ChatFrame1EditBoxHeader:SetFont(addon.FONT, 13, 'OUTLINE')
ChatFrame1EditBoxHeader:SetShadowOffset(0, 0)

-- hide regions
addon:Hide('QuickJoinToastButton')
addon:Hide('ChatFrameChannelButton')
addon:Hide('ChatFrameMenuButton')
addon:Hide('ChatFrame1EditBoxMid')
addon:Hide('ChatFrame1EditBoxLeft')
addon:Hide('ChatFrame1EditBoxRight')

-- expose API for other modules
function addon:AlertChatTab(tabIndex)
	chatTabAlerts[tabIndex] = true
	updateTabColor(tabIndex)
end
