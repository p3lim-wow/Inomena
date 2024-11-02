local _, addon = ...

function addon:GetDurability()
	local lowest = 1
	local average = 0

	local numItems = 0
	for slotIndex in next, INVENTORY_ALERT_STATUS_SLOTS do
		local cur, max = GetInventoryItemDurability(slotIndex)
		if cur ~= nil then
			local perc = cur / max
			if perc < lowest then
				lowest = perc
			end

			average = average + perc
			numItems = numItems + 1
		end
	end

	if numItems > 1 then
		average = average / numItems
	else
		-- player is naked, no point in returning info
		average = 1
	end

	return average, lowest
end
