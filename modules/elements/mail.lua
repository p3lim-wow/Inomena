local E, F = unpack(select(2, ...))

-- remember last recipient
local lastReceipient
function E:MAIL_SEND_SUCCESS()
	if(lastReceipient) then
		SendMailNameEditBox:SetText(lastReceipient)
		SendMailNameEditBox:ClearFocus()
	end
end

hooksecurefunc('SendMail', function(name)
	lastReceipient = name
end)

-- auto send when attachment limit reached
function E:UI_ERROR_MESSAGE(messageID)
	if(messageID == 610) then
		SendMailMailButton:Click()
	end
end

-- auto set subject when sending/requesting money
local function OnTextChanged(self)
	if(self:GetText() ~= '' and SendMailSubjectEditBox:GetText() == '') then
		SendMailSubjectEditBox:SetText(MONEY)
	end
end

SendMailMoneyGold:HookScript('OnTextChanged', OnTextChanged)
SendMailMoneySilver:HookScript('OnTextChanged', OnTextChanged)
SendMailMoneyCopper:HookScript('OnTextChanged', OnTextChanged)
