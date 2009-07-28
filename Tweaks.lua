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
Inomena:RegisterEvent('UPDATE_PENDING_MAIL', function()
	if(HasNewMail() and not MailFrame:IsShown() and (AuctionFrame and not ActionFrame:IsShown())) then -- need more arg checks
		PlaySoundFile([=[Interface\AddOns\Inomena\mail.wav]=])
	end
end)
