local _, Inomena = ...

do
	local last
	Inomena.RegisterEvent('MAIL_SEND_SUCCESS', function()
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
