local _, addon = ...

-- remember last recipient when sending mail

local lastRecipient
function addon:MAIL_SEND_SUCCESS()
	if lastRecipient then
		SendMailNameEditBox:SetText(lastRecipient)
		SendMailNameEditBox:ClearFocus()
	end
end

hooksecurefunc('SendMail', function(name)
	lastRecipient = name
end)

-- auto send mail when reaching attachment limit

function addon:UI_ERROR_MESSAGE(_, message)
	if message == ERR_MAIL_INVALID_ATTACHMENT_SLOT then
		SendMailMailButton:Click()
	end
end

-- auto set subject when sending money

local function updateSubject(self)
	if self:GetText() ~= '' and SendMailSubjectEditBox:GetText() == '' then
		SendMailSubjectEditBox:SetText(MONEY)
	end
end

SendMailMoneyGold:HookScript('OnTextChanged', updateSubject)
SendMailMoneySilver:HookScript('OnTextChanged', updateSubject)
SendMailMoneyCopper:HookScript('OnTextChanged', updateSubject)
