local _, addon = ...

-- add mail indicator to the minimap

local button = Mixin(CreateFrame('Frame', nil, Minimap), addon.widgetMixin)
button:SetPoint('TOPLEFT', 5, -5)
button:SetSize(30, 30)
button:SetScript('OnLeave', GameTooltip_Hide)
button:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')

	if HasNewMail() then
		GameTooltip:AddLine(HAVE_MAIL)

		for _, sender in next, {GetLatestThreeSenders()} do
			-- there's a caching issue with this API ^
			GameTooltip:AddLine(DASH_WITH_TEXT:format(sender), 1, 1, 1)
		end
	else
		GameTooltip:AddLine('No mail')
	end

	-- add lines for pending crafting orders
	local orders = C_CraftingOrders.GetPersonalOrdersInfo()
	if orders and #orders > 0 then
		-- count the orders ourselves
		local numOrders = 0
		for _, order in next, orders do
			numOrders = numOrders + order.numPersonalOrders
		end

		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(numOrders))

		for _, order in next, orders do
			GameTooltip:AddLine(WEEKLY_REWARDS_COMPLETED_ENCOUNTER:format(order.professionName, order.numPersonalOrders), 1, 1, 1)
		end
	end

	GameTooltip:Show()
end)

local icon = button:CreateTexture('OVERLAY')
icon:SetPoint('CENTER')
icon:SetAtlas('mailbox', true)
icon:SetScale(0.7)

local work = button:CreateTexture('OVERLAY')
work:SetAtlas('Vehicle-HammerGold-3', true)

local function updateOrders()
	local orders = C_CraftingOrders.GetPersonalOrdersInfo()
	work:SetShown(orders and #orders > 0)

	if HasNewMail() then
		-- offset the order texture if there's also pending mail
		work:ClearAllPoints()
		work:SetPoint('BOTTOMRIGHT')
		work:SetScale(0.6)
	else
		work:ClearAllPoints()
		work:SetPoint('CENTER')
		work:SetScale(0.7)
	end
end

function addon:UPDATE_PENDING_MAIL()
	-- show button if there is pending mail or work
	button:SetAlpha(HasNewMail() and 1 or 0)

	-- trigger cache
	GetLatestThreeSenders() -- doesn't seem to work well

	-- update orders too to reanchor the work icon
	updateOrders()
end

addon:RegisterEvent('CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS', updateOrders)
addon:RegisterEvent('PLAYER_LOGIN', updateOrders)
