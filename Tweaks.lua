local _, ns = ...

--[[ Copy/paste ]]
ns.Register('PLAYER_LOGIN', function(r, g, b)
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

--[[ Last receipt in mail ]]
do
	local last
	ns.Register('MAIL_SEND_SUCCESS', function()
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

--[[ Auto-repair ]]
ns.Register('MERCHANT_SHOW', function()
	if(CanMerchantRepair()) then
		RepairAllItems()
	end
end)

--[[ Force LFG sound ]]
ns.Register('LFG_PROPOSAL_SHOW', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)

--[[ Force readycheck sound ]]
ReadyCheckListenerFrame:SetScript('OnShow', function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)

--[[ Combat status ]]
ns.Register('PLAYER_REGEN_ENABLED', function()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end)

ns.Register('PLAYER_REGEN_DISABLED', function()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end)

--[[ Ticket command ]]
SLASH_TICKETGM1 = '/gm'
SlashCmdList.TICKETGM = ToggleHelpFrame
