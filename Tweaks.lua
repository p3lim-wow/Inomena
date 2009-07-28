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
	if(HasNewMail() and not MailFrame:IsShown() and (AuctionFrame and not ActionFrame:IsShown())) then -- need more arg checks
		PlaySoundFile([=[Interface\AddOns\Inomena\mail.wav]=])
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
	end

	local orig = SendMailFrame_SendMail
	function SendMailFrame_SendMail(...)
		last = SendMailFrameEditBox:GetText()
		orig(...)
	end
end

--[[ Auto repair ]]
Inomena:Register('MERCHANT_SHOW', function()
	if(CanMerchantRepair()) then
		RepairAllItems()
	end
end

--[[ Force readycheck warning ]]
ReadyCheckListenerFrame:SetScript('OnShow', nil)
Inomena:Register('READY_CHECK', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end
