--[[
	Copyright (c) 2007-2008 Trond A Ekseth
	Copyright (c) 2010-2010 Adrian L Lange

	Permission is hereby granted, free of charge, to any person
	obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following
	conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
--]]

local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', function(self, event) self[event](self) end)
addon:RegisterEvent('PLAYER_LOGIN')

local function OnUpdate(self, elapsed)
	if(self.elapsed > 30) then
		FCF_SelectDockFrame(ChatFrame1)
		self:SetScript('OnUpdate', nil)
		self:UnregisterEvent('CHAT_MSG_WHISPER')
		self:UnregisterEvent('CHAT_MSG_WHISPER_INFORM')
	else
		self.elapsed = self.elapsed + elapsed
	end
end

local function UpdateText(self, ...)
	self = self.GetFontString and self:GetFontString() or self:GetParent():GetFontString()

	local font, size = GameFontNormalSmall:GetFont()
	self:SetFont(font, size, 'OUTLINE')
	self:SetTextColor(...)
end

local function OnEnter(self)
	UpdateText(self, 0, 0.6, 1)
end

local function OnLeave(self)
	if(_G['ChatFrame'..self:GetID()..'TabFlash']:IsShown()) then
		UpdateText(self, 1, 0, 0)
	else
		UpdateText(self, 1, 1, 1)
	end
end

local function OnShow(self)
	UpdateText(self, 1, 0, 0)
end

local function OnHide(self)
	UpdateText(self, 1, 1, 1)
end

local function SkinTab()
	for k, v in pairs(DOCKED_CHAT_FRAMES) do
		local tab = _G[v:GetName()..'Tab']
		local flash = _G[v:GetName()..'TabFlash']

		flash:GetRegions():SetTexture(nil)
		flash:SetScript('OnShow', OnShow)
		flash:SetScript('OnHide', OnHide)

		_G[v:GetName()..'TabLeft']:Hide()
		_G[v:GetName()..'TabMiddle']:Hide()
		_G[v:GetName()..'TabRight']:Hide()

		tab:GetHighlightTexture():SetTexture(nil)
		tab:SetScript('OnEnter', OnEnter)
		tab:SetScript('OnLeave', OnLeave)

		UpdateText(tab, 1, 1, 1)
	end
end

function addon:CHAT_MSG_WHISPER()
	self.elapsed = 0
end

function addon:PLAYER_LOGIN()
	hooksecurefunc('FCF_SelectDockFrame', function(frame)
		if(frame == ChatFrame3) then
			self.elapsed = 0
			self:SetScript('OnUpdate', OnUpdate)
			self:RegisterEvent('CHAT_MSG_WHISPER')
			self:RegisterEvent('CHAT_MSG_WHISPER_INFORM')
		end
	end)

	local orig = FCF_Tab_OnClick
	FCF_Tab_OnClick = function(...)
		orig(...)

		for k, v in pairs(DOCKED_CHAT_FRAMES) do
			OnLeave(_G[v:GetName()..'Tab'])
		end
	end

	FCF_FlashTab = function(self)
		local tab = _G[self:GetName()..'TabFlash']
		if(self ~= SELECTED_DOCK_FRAME and not UIFrameIsFlashing(tab)) then
			tab:Show()
			UIFrameFlash(tab, 0.25, 0.25, -1, nil, 0.5, 0.5)
		end
	end

	FCF_ValidateChatFramePosition = function() end

	DEFAULT_CHATFRAME_ALPHA = 0
	CHAT_TELL_ALERT_TIME = 0

	SkinTab()
end

addon.CHAT_MSG_WHISPER_INFORM = addon.CHAT_MSG_WHISPER
