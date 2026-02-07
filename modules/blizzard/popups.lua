local _, addon = ...

-- don't accidentally deny summons and invites
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil

-- don't ask for written confirmation when deleting items
addon:SafeSetTrue(StaticPopupDialogs.DELETE_ITEM, 'enterClicksFirstButton')
addon:SafeSetTrue(StaticPopupDialogs.DELETE_GOOD_ITEM, 'enterClicksFirstButton')

-- press enter to accept popup (TBH might just hide this if we can)
addon:SafeSetTrue(StaticPopupDialogs.CONFIRM_PURCHASE_NONREFUNDABLE_ITEM, 'enterClicksFirstButton')

-- prevent escape from hiding the logout poput
StaticPopupDialogs.CAMP.hideOnEscape = nil

-- stop waiting for arbitrary timers
addon:HookAddOn('Blizzard_ItemInteractionUI', function()
	StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED.acceptDelay = nil
	StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO.acceptDelay = nil
end)

addon:HookAddOn('Blizzard_WeeklyRewards', function()
	StaticPopupDialogs.CONFIRM_SELECT_WEEKLY_REWARD.acceptDelay = nil
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

-- don't prompt for equipping shareable items
UIParent:UnregisterEvent('EQUIP_BIND_TRADEABLE_CONFIRM')
function addon:EQUIP_BIND_TRADEABLE_CONFIRM(inventorySlot)
	if not InCombatLockdown() then
		EquipPendingItem(inventorySlot)
	end
end

-- don't prompt for selling shareable items
MerchantFrame:UnregisterEvent('MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL')
function addon:MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL()
	if CursorHasItem() then
		SellCursorItem()
	end
end

-- hide repetitive help tips
C_CVar.RegisterCVar('hideHelptips', 1)
for index = 1, NUM_LE_FRAME_TUTORIALS do
	C_CVar.SetCVarBitfield('closedInfoFrames', index, true)
end
for index = 1, #Enum.FrameTutorialAccount do
	C_CVar.SetCVarBitfield('closedInfoFramesAccountWide', index, true)
end
