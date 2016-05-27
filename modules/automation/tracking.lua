local E, F = unpack(select(2, ...))

function E:UPDATE_INVENTORY_DURABILITY()
	local alert = 0
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if(status > alert) then
			alert = status
		end
	end

	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == MINIMAP_TRACKING_REPAIR) then
			return SetTracking(index, alert > 0)
		end
	end
end

function E:UPDATE_PENDING_MAIL()
	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == MINIMAP_TRACKING_MAILBOX) then
			return SetTracking(index, HasNewMail() and not active)
		end
	end
end
