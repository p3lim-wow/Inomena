local E, F, C = unpack(select(2, ...))

local function Scroll(self, direction)
	if(direction > 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToTop()
		elseif(IsControlKeyDown()) then
			self:PageUp()
		else
			self:ScrollUp()
		end
	elseif(direction < 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToBottom()
		elseif(IsControlKeyDown()) then
			self:PageDown()
		else
			self:ScrollDown()
		end
	end
end

local function UpdateTab(self)
	if(self:GetObjectType() ~= 'Button') then
		self = _G[self:GetName() .. 'Tab']
	end

	local Tab = C.BfA and self.Text or self:GetFontString()
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

local function UpdateFont(Frame)
	Frame:SetFontObject('PixelFontNormal')
end

function F.SkinChatWindow(index)
	local Frame = _G['ChatFrame' .. index]
	UpdateFont(Frame)
	Frame:SetClampRectInsets(0, 0, 0, 0)
	Frame:SetSpacing(1.4)
	Frame:SetScript('OnMouseWheel', Scroll)
	Frame:EnableMouseWheel(true)
	Frame.buttonFrame:Hide()

	local EditBox = _G['ChatFrame' .. index .. 'EditBox']
	EditBox:ClearAllPoints()
	EditBox:SetPoint('TOPRIGHT', Frame, 'BOTTOMRIGHT', 0, 5)
	EditBox:SetPoint('TOPLEFT', Frame, 'BOTTOMLEFT', 0, 5)
	EditBox:SetFontObject('PixelFontNormal')
	EditBox:SetAltArrowKeyMode(false)

	EditBox.focusLeft:SetTexture(nil)
	EditBox.focusMid:SetTexture(nil)
	EditBox.focusRight:SetTexture(nil)

	EditBox.header:ClearAllPoints()
	EditBox.header:SetPoint('LEFT')
	EditBox.header:SetFontObject('PixelFontNormal')

	_G['ChatFrame' .. index .. 'EditBoxLeft']:SetTexture(nil)
	_G['ChatFrame' .. index .. 'EditBoxMid']:SetTexture(nil)
	_G['ChatFrame' .. index .. 'EditBoxRight']:SetTexture(nil)

	local Tab = _G['ChatFrame' .. index .. 'Tab']
	Tab:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	Tab:SetAlpha(0)
	Tab:HookScript('OnEnter', UpdateTab)
	Tab:HookScript('OnLeave', UpdateTab)
	Tab:SetScript('OnDragStart', nil)

	local font, size, flags = PixelFontNormal:GetFont()
	Tab.Text:SetFont(font, size, flags)
	Tab.Text:SetShadowOffset(0, 0)

	for _, region in next, {Tab:GetRegions()} do
		if(region:GetObjectType() == 'Texture') then
			region:SetTexture(nil)
		end
	end

	UpdateTab(Tab)
end

function E:UPDATE_CHAT_WINDOWS()
	for index = 1, NUM_CHAT_WINDOWS do
		UpdateFont(_G['ChatFrame' .. index])
	end
end

function E:PLAYER_LOGIN()
	DEFAULT_CHATFRAME_ALPHA = 0
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.7

	CHAT_TAB_SHOW_DELAY = 0
	CHAT_TAB_HIDE_DELAY = 0.5
	CHAT_FRAME_FADE_TIME = 0
	CHAT_FRAME_FADE_OUT_TIME = 0.5

	for index = 1, NUM_CHAT_WINDOWS do
		F.SkinChatWindow(index)
	end

	for _, button in next, {
		'QuickJoinToastButton',
		'ChatFrameChannelButton',
		'ChatFrameToggleVoiceDeafenButton',
		'ChatFrameToggleVoiceMuteButton',
		'ChatFrameMenuButton',
	} do
		if(_G[button]) then
			_G[button]:Hide()
		end
	end

	hooksecurefunc('FCFTab_UpdateColors', UpdateTab)
	hooksecurefunc('FCF_StartAlertFlash', UpdateTab)
	hooksecurefunc('FCF_FadeOutChatFrame', UpdateTab)
end
