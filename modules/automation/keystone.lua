local _, addon = ...

-- automatically place keystones in the font of power
function addon:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN()
	for bagID = Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do
		for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
			local itemLink = C_Container.GetContainerItemLink(bagID, slotID)
			if itemLink and itemLink:match('|Hkeystone:') then
				C_Container.PickupContainerItem(bagID, slotID)
				if CursorHasItem() then
					C_ChallengeMode.SlotKeystone()
					return
				end
			end
		end
	end
end
