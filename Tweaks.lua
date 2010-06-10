local _, ns = ...

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
