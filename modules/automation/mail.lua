local _, addon = ...

local MINIMAP_TRACKING_MAILBOX = _G.MINIMAP_TRACKING_MAILBOX -- globalstring
local MONEY = _G.MONEY -- globalstring

-- track mailboxes if we have pending mail
function addon:UPDATE_PENDING_MAIL()
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		if C_Minimap.GetTrackingInfo(index) == MINIMAP_TRACKING_MAILBOX then
			C_Minimap.SetTracking(index, HasNewMail())
			break
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
	if messageID == 655 then -- "You cannot attach more than 12 items to mail."
		-- TODO: find an enum or something for this, as it changes every patch
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
