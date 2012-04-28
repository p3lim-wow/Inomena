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

	local skipNum, lastNum
	local function GetMail()
		if(GetInboxNumItems() - skipNum <= 0) then
			button:Enable()
			button:UnregisterEvent('MAIL_INBOX_UPDATE')
			return
		end

		local index = 1 + skipNum
		local _, _, _, _, money, cod, _, multiple, _, _, _, _, _, single = GetInboxHeaderInfo(index)
		if(cod > 0) then
			skipNum = skipNum + 1
			GetMail(self)
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

		GetMail(self)
	end)

	button:SetScript('OnClick', function(self)
		self:RegisterEvent('MAIL_INBOX_UPDATE')
		self:Disable()

		lastNum = 0
		skipNum = 0

		GetMail(self)
	end)

	local initialized
	Inomena.RegisterEvent('MAIL_SHOW', function()
		if(initialized) then
			button:Enable()
			return
		end

		button:SetPoint('BOTTOM', -12, 88)
		button:SetSize(90, 25)
		button:SetText(OPENMAIL)

		InboxFrame:HookScript('OnUpdate', UpdateInbox)

		initialized = true
	end)
end
