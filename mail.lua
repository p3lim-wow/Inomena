local _, Inomena = ...

do
	local lastReceipient
	Inomena.RegisterEvent('MAIL_SEND_SUCCESS', function()
		if(lastReceipient) then
			SendMailNameEditBox:SetText(lastReceipient)
			SendMailNameEditBox:ClearFocus()
		end
	end)

	hooksecurefunc('SendMail', function(name)
		lastReceipient = name
	end)
end

Inomena.RegisterEvent('UI_ERROR_MESSAGE', function(msg)
	if(msg == ERR_MAIL_INVALID_ATTACHMENT_SLOT) then
		SendMailMailButton:Click()
	end
end)

do
	local function OnTextChanged(self)
		if(self:GetText() ~= '' and SendMailSubjectEditBox:GetText() == '') then
			SendMailSubjectEditBox:SetText(MONEY)
		end
	end

	SendMailMoneyGold:HookScript('OnTextChanged', OnTextChanged)
	SendMailMoneySilver:HookScript('OnTextChanged', OnTextChanged)
	SendMailMoneyCopper:HookScript('OnTextChanged', OnTextChanged)
end

do
	local totalElapsed = 0
	InboxFrame:HookScript('OnUpdate', function(self, elapsed)
		if(totalElapsed < 10) then
			totalElapsed = totalElapsed + elapsed
		else
			totalElapsed = 0

			CheckInbox()
		end
	end)
end

do
	local Button = CreateFrame('Button', nil, InboxFrame, 'UIPanelButtonTemplate')
	Button:SetPoint('BOTTOM', -28, 100)
	Button:SetSize(90, 25)
	Button:SetText(QUICKBUTTON_NAME_EVERYTHING)

	local lastIndex
	local function GetMail()
		if(GetInboxNumItems() - lastIndex <= 0) then
			Button:GetScript('OnHide')(Button)
			return
		end

		local index = lastIndex + 1
		local _, _, sender, _, money, cod, _, numItems, isRead, _, _, _, numStacks = GetInboxHeaderInfo(index)

		if(money > 0) then
			TakeInboxMoney(index)
		end

		if(numItems or numStacks) then
			AutoLootMailItem(index)
		end

		if(sender == 'The Postmaster' and not numItems and money == 0) then
			DeleteInboxItem(index)
		elseif(isRead or cod > 0) then
			lastIndex = index
		end

		C_Timer.After(1/2, GetMail)
	end

	Button:SetScript('OnClick', function(self)
		self:Disable()
		lastIndex = 0
		GetMail()
	end)

	Button:SetScript('OnHide', function(self)
		self:UnregisterEvent('MAIL_INBOX_UPDATE')
		self:Enable()
	end)
end
