local E, F = unpack(select(2, ...))

-- Auto-accept replacing enchants
function E:REPLACE_ENCHANT()
	if(TradeSkillFrame and TradeSkillFrame:IsShown()) then
		ReplaceEnchant()
		StaticPopup_Hide('REPLACE_ENCHANT')
	end
end

-- Make summon and invite popups escape-proof
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = false
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = false

-- Remove the editbox for deleting "good" items
StaticPopupDialogs.DELETE_ITEM.enterClicksFirstButton = true
StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM

-- Use the enter key to purchase items from currencies
StaticPopupDialogs.CONFIRM_PURCHASE_TOKEN_ITEM.enterClicksFirstButton = true

hooksecurefunc('StaticPopup_Show', function(which, _, _, data)
	if(which == 'CONFIRM_LEARN_SPEC' and (not data.previewSpecCost or data.previewSpecCost <= 0)) then
		-- Auto-confirm changing specs
		StaticPopup_Hide(which)
		SetSpecialization(data.previewSpec, data.isPet)
	elseif(which == 'ABANDON_QUEST') then
		-- Avoid having to click Abandon twice
		StaticPopup_Hide(which)
		StaticPopupDialogs[which].OnAccept()
	end
end)

function E:MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL()
	StaticPopup_Hide('CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL')
	SellCursorItem()
end

function E:EQUIP_BIND_TRADEABLE_CONFIRM(slot)
	EquipPendingItem(slot)
	StaticPopup_Hide('EQUIP_BIND_TRADEABLE')
end
