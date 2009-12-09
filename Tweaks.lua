--[[ Copy/paste function to colorpicker ]]
Inomena:Register('PLAYER_LOGIN', function(r, g, b)
	local copy = CreateFrame('Button', nil, ColorPickerFrame, 'UIPanelButtonTemplate')
	copy:SetPoint('BOTTOMLEFT', ColorPickerFrame, 'TOPLEFT', 208, -110)
	copy:SetHeight(20)
	copy:SetWidth(80)
	copy:SetText('Copy')
	copy:SetScript('OnClick', function() r, g, b = ColorPickerFrame:GetColorRGB() end)

	local paste = CreateFrame('Button', nil, ColorPickerFrame, 'UIPanelButtonTemplate')
	paste:SetPoint('BOTTOMLEFT', ColorPickerFrame, 'TOPLEFT', 208, -135)
	paste:SetHeight(20)
	paste:SetWidth(80)
	paste:SetText('Paste')
	paste:SetScript('OnClick', function() ColorPickerFrame:SetColorRGB(r, g, b) end)
end)

--[[ Sound on new mail ]]
Inomena:Register('UPDATE_PENDING_MAIL', function()
	if(HasNewMail() and not MailFrame:IsShown() and (AuctionFrame and not AuctionFrame:IsShown())) then -- need more arg checks
		PlaySoundFile([=[Interface\AddOns\Inomena\media\mail.wav]=])
	end
end)

--[[ Last receipt in mail ]]
do
	local last
	Inomena:Register('MAIL_SEND_SUCCESS', function()
		if(last) then
			SendMailNameEditBox:SetText(last)
			SendMailNameEditBox:HighlightText()
		end
	end)

	local orig = SendMailFrame_SendMail
	function SendMailFrame_SendMail(...)
		last = SendMailNameEditBox:GetText()
		orig(...)
	end
end

--[[ Auto repair ]]
Inomena:Register('MERCHANT_SHOW', function(self)
	local val, afford = GetRepairAllCost()
	if(CanMerchantRepair() and afford) then
		if(val > 1e4) then
			self:Print(format('Repaired for |cffffff66%d|r|TInterface\\MoneyFrame\\UI-GoldIcon:18|t |cffc0c0c0%d|r|TInterface\\MoneyFrame\\UI-SilverIcon:18|t |cffcc9900%d|r|TInterface\\MoneyFrame\\UI-CopperIcon:18|t', val / 1e4, mod(val, 1e4) / 1e2, mod(val, 1e2)))
		elseif(val > 1e2) then
			self:Print(format('Repaired for |cffc0c0c0%d|r|TInterface\\MoneyFrame\\UI-SilverIcon:18|t |cffcc9900%d|r|TInterface\\MoneyFrame\\UI-CopperIcon:18|t', val / 1e2, mod(val, 1e2)))
		else
			self:Print(format('Repaired for |cffcc9900%d|r|TInterface\\MoneyFrame\\UI-CopperIcon:18|t', val))
		end
	
		RepairAllItems()
	end
end)

--[[ Force readycheck warning ]]
ReadyCheckListenerFrame:SetScript('OnShow', nil)
Inomena:Register('READY_CHECK', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)

--[[ Worldmap enhancing 
UIPanelWindows.WorldMapFrame = {area = 'center', pushable = 9}
hooksecurefunc(WorldMapFrame, 'Show', function(self)
	self:SetScale(0.75)
	self:EnableKeyboard(false)
	self:EnableMouse(false)
	BlackoutWorld:Hide()
end)
--]]
--[[ GM chat frame enhancement ]]
Inomena:Register('ADDON_LOADED', function(self, event, name)
	if(name ~= 'Blizzard_GMChatUI') then return end

	GMChatFrame:EnableMouseWheel()
	GMChatFrame:SetScript('OnMouseWheel', ChatFrame1:GetScript('OnMouseWheel'))
	GMChatFrame:SetHeight(GMChatFrame:GetHeight() * 3)

	self:UnregisterEvent(event)
end)

--[[ Entering/leaving combat messages ]]
Inomena:Register('PLAYER_REGEN_ENABLED', function()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end)

Inomena:Register('PLAYER_REGEN_DISABLED', function()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end)

--[[ GM ticket shortcut ]]
SLASH_TICKETGM1 = '/gm'
SlashCmdList.TICKETGM = ToggleHelpFrame
