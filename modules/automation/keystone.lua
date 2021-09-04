local _, addon = ...

-- automatically place keystones in the font of power
function addon:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN()
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local itemLink = GetContainerItemLink(bagID, slotID)
			if itemLink and itemLink:match('|Hkeystone:') then
				PickupContainerItem(bagID, slotID)
				if CursorHasItem() then
					C_ChallengeMode.SlotKeystone()
					return
				end
			end
		end
	end
end
