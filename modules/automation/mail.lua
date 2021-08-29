local _, addon = ...

-- track mailboxes if we have pending mail
function addon:UPDATE_PENDING_MAIL()
	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if name == MINIMAP_TRACKING_MAILBOX then
			return SetTracking(index, HasNewMail() and not active)
		end
	end
end

-- remember last recipient
local lastReceipient
function addon:MAIL_SEND_SUCCESS()
	if lastReceipient then
		SendMailNameEditBox:SetText(lastReceipient)
		SendMailNameEditBox:ClearFocus()
	end
end

hooksecurefunc('SendMail', function(name)
	lastReceipient = name
end)

-- auto send when attachment limit reached
function addon:UI_ERROR_MESSAGE(messageID)
	if messageID == 629 then
		SendMailMailButton:Click()
	end
end

-- auto set subject when sending/requesting money
local function OnTextChanged(self)
	if self:GetText() ~= '' and SendMailSubjectEditBox:GetText() == '' then
		SendMailSubjectEditBox:SetText(MONEY)
	end
end

SendMailMoneyGold:HookScript('OnTextChanged', OnTextChanged)
SendMailMoneySilver:HookScript('OnTextChanged', OnTextChanged)
SendMailMoneyCopper:HookScript('OnTextChanged', OnTextChanged)
