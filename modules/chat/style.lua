local E, F, C = unpack(select(2, ...))

local function Scroll(self, direction)
	if(direction > 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToTop()
		elseif(IsControlKeyDown()) then
			self:PageUp()
		end
	elseif(direction < 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToBottom()
		elseif(IsControlKeyDown()) then
			self:PageDown()
		end
	end
end

local function UpdateTab(self)
	if(self:GetObjectType() ~= 'Button') then
		self = _G[self:GetName() .. 'Tab']
	end

	local Tab = self.fontString
	if(Tab) then
		if(self:IsMouseOver()) then
			Tab:SetTextColor(0, 0.6, 1)
		elseif(self.alerting) then
			Tab:SetTextColor(1, 0, 0)
		elseif(self:GetID() == SELECTED_CHAT_FRAME:GetID()) then
			Tab:SetTextColor(1, 1, 1)
		else
			Tab:SetTextColor(0.5, 0.5, 0.5)
		end
	end
end

local font, size, outline = SempliceNormal:GetFont()
function F.SkinChatWindow(index)
	local Frame = _G['ChatFrame' .. index]
	Frame:SetFont(font, size, outline)
	Frame:SetShadowOffset(0, 0)
	Frame:SetClampRectInsets(0, 0, 0, 0)
	Frame:SetSpacing(1.4)
	Frame:HookScript('OnMouseWheel', Scroll)
	Frame.buttonFrame:Hide()

	local EditBox = _G['ChatFrame' .. index .. 'EditBox']
	EditBox:ClearAllPoints()
	EditBox:SetPoint('TOPRIGHT', Frame, 'BOTTOMRIGHT', 0, 5)
	EditBox:SetPoint('TOPLEFT', Frame, 'BOTTOMLEFT', 0, 5)
	EditBox:SetFont(font, size, outline)
	EditBox:SetShadowOffset(0, 0)
	EditBox:SetAltArrowKeyMode(false)

	EditBox.focusLeft:SetTexture(nil)
	EditBox.focusMid:SetTexture(nil)
	EditBox.focusRight:SetTexture(nil)

	EditBox.header:ClearAllPoints()
	EditBox.header:SetPoint('LEFT')
	EditBox.header:SetFont(font, size, outline)
	EditBox.header:SetShadowOffset(0, 0)

	_G['ChatFrame' .. index .. 'EditBoxLeft']:SetTexture(nil)
	_G['ChatFrame' .. index .. 'EditBoxMid']:SetTexture(nil)
	_G['ChatFrame' .. index .. 'EditBoxRight']:SetTexture(nil)

	local Tab = _G['ChatFrame' .. index .. 'Tab']
	Tab:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	Tab:SetAlpha(0)
	Tab:HookScript('OnEnter', UpdateTab)
	Tab:HookScript('OnLeave', UpdateTab)
	Tab:SetScript('OnDragStart', nil)

	Tab.fontString = Tab:GetFontString()
	Tab.fontString:SetFont(font, size, outline)
	Tab.fontString:SetShadowOffset(0, 0)

	Tab.leftTexture:SetTexture(nil)
	Tab.middleTexture:SetTexture(nil)
	Tab.rightTexture:SetTexture(nil)

	Tab.leftHighlightTexture:SetTexture(nil)
	Tab.middleHighlightTexture:SetTexture(nil)
	Tab.rightHighlightTexture:SetTexture(nil)

	Tab.leftSelectedTexture:SetTexture(nil)
	Tab.middleSelectedTexture:SetTexture(nil)
	Tab.rightSelectedTexture:SetTexture(nil)

	Tab.glow:SetTexture(nil)

	if(Tab.conversationIcon) then
		Tab.conversationIcon:SetTexture(nil)
	end

	UpdateTab(Tab)
end

function E:PLAYER_LOGIN()
	DEFAULT_CHATFRAME_ALPHA = 0
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.7

	for index = 1, NUM_CHAT_WINDOWS do
		F.SkinChatWindow(index)
	end

	ChatFrameMenuButton:SetAlpha(0)
	ChatFrameMenuButton:EnableMouse(false)
	FriendsMicroButton:Hide()

	hooksecurefunc('FCFTab_UpdateColors', UpdateTab)
	hooksecurefunc('FCF_StartAlertFlash', UpdateTab)
	hooksecurefunc('FCF_FadeOutChatFrame', UpdateTab)
end

function E:UPDATE_CHAT_COLOR_NAME_BY_CLASS(type, enabled)
	if(not enabled) then
		SetChatColorNameByClass(type, true)
	end
end
