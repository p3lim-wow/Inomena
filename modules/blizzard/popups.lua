local _, addon = ...

-- safely set boolean(-ish) state on blizzard objects without taint
-- this is _super_ hacky, but it's the only way we can do this safely
local function SafeSetTrue(object, key)
	TextureLoadingGroupMixin.AddTexture({textures = object}, key)
end

local function SafeSetNil(object, key)
	TextureLoadingGroupMixin.RemoveTexture({textures = object}, key)
end

-- don't accidentally deny summons and invites
SafeSetNil(StaticPopupDialogs.PARTY_INVITE, 'hideOnEscape')
SafeSetNil(StaticPopupDialogs.CONFIRM_SUMMON, 'hideOnEscape')
SafeSetNil(StaticPopupDialogs.AREA_SPIRIT_HEAL, 'hideOnEscape')

-- don't ask for written confirmation when deleting items
SafeSetTrue(StaticPopupDialogs.DELETE_ITEM, 'enterClicksFirstButton')
SafeSetTrue(StaticPopupDialogs.DELETE_GOOD_ITEM, 'enterClicksFirstButton')

-- press enter to accept popup (TBH might just hide this if we can)
SafeSetTrue(StaticPopupDialogs.CONFIRM_PURCHASE_NONREFUNDABLE_ITEM, 'enterClicksFirstButton')

-- prevent escape from hiding the logout poput
StaticPopupDialogs.CAMP.hideOnEscape = false

-- stop waiting for arbitrary timers
addon:HookAddOn('Blizzard_ItemInteractionUI', function()
	SafeSetNil(StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED, 'acceptDelay')
	SafeSetNil(StaticPopupDialogs.ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO, 'acceptDelay')
end)

addon:HookAddOn('Blizzard_WeeklyRewards', function()
	SafeSetNil(StaticPopupDialogs.CONFIRM_SELECT_WEEKLY_REWARD, 'acceptDelay')
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
