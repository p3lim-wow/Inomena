local _, addon = ...

-- don't accidentally deny summons and invites
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = false
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = false

-- don't ask for written confirmation when deleting items
StaticPopupDialogs.DELETE_ITEM.enterClicksFirstButton = true
StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM

-- don't prompt when buying using a currency other than gold
function StaticPopupDialogs.CONFIRM_PURCHASE_TOKEN_ITEM:OnShow()
	StaticPopup_Hide(self.which)
	StaticPopupDialogs[self.which].OnAccept()
end

-- don't prompt to sell shareable items
function StaticPopupDialogs.CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL:OnShow()
	StaticPopupDialogs[self.which].OnAccept()
	StaticPopup_Hide(self.which)
end

-- don't prompt when abandoning quests
function StaticPopupDialogs.ABANDON_QUEST:OnShow()
	StaticPopup_Hide(self.which)
	StaticPopupDialogs[self.which].OnAccept()
end

-- don't prompt when replacing enchants when professions window is open
function StaticPopupDialogs.REPLACE_ENCHANT:OnShow()
	if ProfessionsFrame and ProfessionsFrame:IsShown() then
		StaticPopupDialogs[self.which].OnAccept()
		StaticPopup_Hide(self.which)
	end
end

-- don't prompt to equip shareable items
function addon:EQUIP_BIND_TRADEABLE_CONFIRM(slot)
	if not InCombatLockdown() then
		-- for whatever reason, this non-framexml-API will taint the bags,
		-- which makes absolutely no sense since you can't equip items in combat anyways,
		-- and this popup wouldn't show
		EquipPendingItem(slot)
		StaticPopup_Hide('EQUIP_BIND_TRADEABLE')
	end
end
