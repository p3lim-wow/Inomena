local _, addon = ...

-- track repair vendors when equipment is damaged, and mailboxes when mail has arrived

local function getTrackingIndex(name)
	-- iterate through tracking types to find the tracking index by name
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local trackingInfo = C_Minimap.GetTrackingInfo(index)
		if trackingInfo and trackingInfo.name == name then
			return index
		end
	end
end

function addon:UPDATE_INVENTORY_DURABILITY()
	-- find equipment with the most durability lost
	local worstStatus = 0
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if status > worstStatus then
			worstStatus = status
		end
	end

	local trackingIndex = getTrackingIndex(MINIMAP_TRACKING_REPAIR)
	if trackingIndex then
		-- enable tracking if equipment is damaged
		C_Minimap.SetTracking(trackingIndex, worstStatus > 0)
	end
end

function addon:UPDATE_PENDING_MAIL()
	local trackingIndex = getTrackingIndex(MINIMAP_TRACKING_MAILBOX)
	if trackingIndex then
		-- enable tracking if there is mail
		C_Minimap.SetTracking(trackingIndex, HasNewMail())
	end
end
