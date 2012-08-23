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

Inomena.RegisterEvent('UPDATE_PENDING_MAIL', function()
	for index = 1, GetNumTrackingTypes() do
		local name, texture, active = GetTrackingInfo(index)
		if(name == MINIMAP_TRACKING_MAILBOX) then
			if(HasNewMail() and not active) then
				return SetTracking(index, true)
			elseif(not HasNewMail() and active) then
				return SetTracking(index, false)
			end
		end
	end
end)

Inomena.RegisterEvent('UI_ERROR_MESSAGE', function(msg)
	if(msg == ERR_MAIL_INVALID_ATTACHMENT_SLOT) then
		SendMailMailButton:Click()
	end
end)

do
	local button = CreateFrame('Button', nil, InboxFrame, 'UIPanelButtonTemplate')

	local totalElapsed = 0
	local function UpdateInbox(self, elapsed)
		if(totalElapsed < 10) then
			totalElapsed = totalElapsed + elapsed
		else
			totalElapsed = 0

			CheckInbox()
		end
	end

	local function MoneySubject(self)
		if(self:GetText() ~= '' and SendMailSubjectEditBox:GetText() == '') then
			SendMailSubjectEditBox:SetText(MONEY)
		end
	end

	local function GetFreeSlots()
		local slots = 0
		for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local free, family = GetContainerNumFreeSlots(bag)
			if(family == 0) then
				slots = slots + free
			end
		end

		return slots
	end

	local skipNum, lastNum, cashOnly, unreadOnly
	local function GetMail()
		if(GetInboxNumItems() - skipNum <= 0) then
			button:Enable()
			button:UnregisterEvent('MAIL_INBOX_UPDATE')
			return
		end

		local index = 1 + skipNum
		local _, _, _, _, money, cod, _, multiple, read, _, _, _, _, single = GetInboxHeaderInfo(index)

		if(cod > 0 or (cashOnly and multiple) or (unreadOnly and read)) then
			skipNum = skipNum + 1
			GetMail()
		elseif(money > 0) then
			TakeInboxMoney(index)
		elseif(single and (GetFreeSlots() > 6)) then
			AutoLootMailItem(index)
		elseif(multiple and (GetFreeSlots() + multiple > 6)) then
			AutoLootMailItem(index)
		end
	end

	button:SetScript('OnEvent', function(self)
		local num = GetInboxNumItems()
		if(lastNum ~= num) then
			lastNum = num
		else
			return
		end

		GetMail()
	end)

	button:SetScript('OnClick', function(self)
		self:RegisterEvent('MAIL_INBOX_UPDATE')
		self:Disable()

		cashOnly = IsShiftKeyDown()
		unreadOnly = IsControlKeyDown()
		lastNum = 0
		skipNum = 0

		GetMail()
	end)

	local initialized
	Inomena.RegisterEvent('MAIL_SHOW', function()
		if(initialized) then
			button:Enable()
			button:SetText(QUICKBUTTON_NAME_EVERYTHING)
			return
		end

		button:SetPoint('BOTTOM', -28, 100)
		button:SetSize(90, 25)
		button:SetText(QUICKBUTTON_NAME_EVERYTHING)

		InboxFrame:HookScript('OnUpdate', UpdateInbox)

		SendMailMoneyGold:HookScript('OnTextChanged', MoneySubject)
		SendMailMoneySilver:HookScript('OnTextChanged', MoneySubject)
		SendMailMoneyCopper:HookScript('OnTextChanged', MoneySubject)

		initialized = true
	end)

	Inomena.RegisterEvent('MODIFIER_STATE_CHANGED', function()
		if(not InboxFrame:IsShown()) then return end

		if(IsShiftKeyDown()) then
			button:SetText('Money')
		elseif(IsControlKeyDown()) then
			button:SetText('Unread')
		else
			button:SetText('Everything')
		end
	end)
end
