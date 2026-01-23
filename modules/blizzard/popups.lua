local _, addon = ...

-- don't accidentally deny summons and invites
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = false
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = false
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = false

-- don't ask for written confirmation when deleting items
StaticPopupDialogs.DELETE_ITEM.enterClicksFirstButton = true

-- prevent escape from hiding the logout poput
StaticPopupDialogs.CAMP.hideOnEscape = false

-- stop waiting for arbitrary timers
addon:HookAddOn('Blizzard_ItemInteractionUI', function()
	StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED.acceptDelay = 1
	StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO.acceptDelay = 1
end)

addon:HookAddOn('Blizzard_WeeklyRewards', function()
	StaticPopupDialogs.CONFIRM_SELECT_WEEKLY_REWARD.acceptDelay = 1
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
