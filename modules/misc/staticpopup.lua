local E, F = unpack(select(2, ...))

-- Auto-accept replacing enchants
function E:REPLACE_ENCHANT()
	if(TradeSkillFrame and TradeSkillFrame:IsShown()) then
		ReplaceEnchant()
		StaticPopup_Hide('REPLACE_ENCHANT')
	end
end

-- Make summon and invite popups escape-proof
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = 0
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = 0

-- Remove the editbox for deleting "good" items
StaticPopupDialogs.DELETE_GOOD_ITEM.hasEditBox = false
StaticPopupDialogs.DELETE_GOOD_ITEM.OnShow = function(self)
	self.button1:Enable()
end

-- Use the enter key to purchase items from currencies
StaticPopupDialogs.CONFIRM_PURCHASE_TOKEN_ITEM.enterClicksFirstButton = true
