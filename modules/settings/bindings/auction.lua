local _, addon = ...

-- press spacebar to post auction

local RESET = [[
	if name == 'state-combat' and value == 'clear' then
		self:ClearBindings()
	end
]]

local function setup(auctionType)
	local button = addon:CreateBindButton(auctionType, 'SecureHandlerStateTemplate, SecureHandlerAttributeTemplate')
	button:SetAttribute('_onattributechanged', RESET)
	button:SetScript('OnClick', function()
		AuctionHouseFrame[auctionType]:PostItem()
	end)

	local PostButton = AuctionHouseFrame[auctionType].PostButton
	PostButton:HookScript('OnEnable', function()
		if InCombatLockdown() then
			return
		end

		button:Bind('SPACE')
		RegisterStateDriver(button, 'combat', '[combat] clear; nothing')
	end)

	PostButton:HookScript('OnDisable', function()
		button:Unbind()
		addon:Defer('UnregisterStateDriver', button, 'combat')
	end)
end

addon:HookAddOn('Blizzard_AuctionHouseUI', function()
	setup('ItemSellFrame')
	setup('CommoditiesSellFrame')
end)
