local _, addon = ...

-- don't accidentally deny summons and invites
addon:SafeSetNil(StaticPopupDialogs.PARTY_INVITE, 'hideOnEscape')
addon:SafeSetNil(StaticPopupDialogs.CONFIRM_SUMMON, 'hideOnEscape')
addon:SafeSetNil(StaticPopupDialogs.AREA_SPIRIT_HEAL, 'hideOnEscape')

-- don't ask for written confirmation when deleting items
addon:SafeSetTrue(StaticPopupDialogs.DELETE_ITEM, 'enterClicksFirstButton')
addon:SafeSetTrue(StaticPopupDialogs.DELETE_GOOD_ITEM, 'enterClicksFirstButton')

-- press enter to accept popup (TBH might just hide this if we can)
addon:SafeSetTrue(StaticPopupDialogs.CONFIRM_PURCHASE_NONREFUNDABLE_ITEM, 'enterClicksFirstButton')

-- prevent escape from hiding the logout poput
addon:SafeSetNil(StaticPopupDialogs.CAMP, 'hideOnEscape')

-- stop waiting for arbitrary timers
addon:HookAddOn('Blizzard_ItemInteractionUI', function()
	addon:SafeSetNil(StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED, 'acceptDelay')
	addon:SafeSetNil(StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO, 'acceptDelay')
end)

addon:HookAddOn('Blizzard_WeeklyRewards', function()
	addon:SafeSetNil(StaticPopupDialogs.CONFIRM_SELECT_WEEKLY_REWARD, 'acceptDelay')
end)

-- confirm looting items that bind on pickup
UIParent:UnregisterEvent('LOOT_BIND_CONFIRM')
function addon:LOOT_BIND_CONFIRM(lootSlot)
	ConfirmLootSlot(lootSlot)
end

-- click through toasts
hooksecurefunc(EventToastManagerFrame, 'DisplayToast', function(self)
	self:EnableMouse(false)

	if self.currentDisplayingToast then
		self.currentDisplayingToast:EnableMouse(false)
		self.currentDisplayingToast.TitleTextMouseOverFrame:EnableMouse(false)
		self.currentDisplayingToast.SubTitleMouseOverFrame:EnableMouse(false)
	end
end)
