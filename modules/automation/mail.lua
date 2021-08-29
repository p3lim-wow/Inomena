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
