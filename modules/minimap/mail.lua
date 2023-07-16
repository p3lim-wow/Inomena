local addonName, addon = ...

local mail = addon:CreateButton('Button', addonName .. 'MailButton', Minimap, 'SecureActionButtonTemplate')
mail:SetPoint('TOPLEFT', 5, -5)
mail:SetSize(30, 30)
mail:SetAttribute('type', 'macro')

local icon = mail:CreateTexture('$parentIcon', 'OVERLAY')
icon:SetPoint('CENTER')
icon:SetAtlas('mailbox', true)
icon:SetScale(0.7)

local work = mail:CreateTexture('$parentWorkIcon', 'OVERLAY')
work:SetAtlas('Vehicle-HammerGold-3', true)

-- show icon if there is pending mail
local function updateWork()
	local orders = C_CraftingOrders.GetPersonalOrdersInfo()
	work:SetShown(orders and #orders > 0)

	if HasNewMail() then
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
	icon:SetAlpha(HasNewMail() and 1 or 0)
	updateWork()
end

addon:RegisterEvent('CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS', updateWork)
addon:RegisterEvent('PLAYER_LOGIN', updateWork)

-- create an API for summonable mailboxes
local selectedMailbox = 1
local MAILBOXES = {
	{'toy', 40768}, -- MOLL-E
	{'toy', 156833}, -- Katy's Stampwhistle
	{'toy', 194885}, -- Ohuna Perch
	{'spell', 255661}, -- Cantrips (Nightborne racial)
}

local function cooldownWrapper(start, duration)
	return start > 0 and start - GetTime() + duration
end

local function updateTooltip(_, ...)
	GameTooltip:SetOwner(mail, 'ANCHOR_BOTTOMLEFT')

	if HasNewMail() then
		GameTooltip:AddLine(_G.HAVE_MAIL)
		for _, sender in next, {GetLatestThreeSenders()} do
			GameTooltip:AddLine(_G.DASH_WITH_TEXT:format(sender), 1, 1, 1)
		end
	else
		GameTooltip:AddLine('No mail')
	end

	local orders = C_CraftingOrders.GetPersonalOrdersInfo()
	if orders and #orders > 0 then
		local numOrders = 0
		for _, order in next, orders do
			numOrders = numOrders + order.numPersonalOrders
		end

		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(_G.PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(numOrders))
		for _, order in next, orders do
			GameTooltip:AddLine(_G.WEEKLY_REWARDS_COMPLETED_ENCOUNTER:format(order.professionName, order.numPersonalOrders), 1, 1, 1)
		end
	end

	GameTooltip:AddLine(' ')
	for index, info in next, MAILBOXES do
		local title, cooldown, _
		if info[1] == 'toy' then
			_, title = GetItemInfo(info[2])
			cooldown = cooldownWrapper(GetItemCooldown(info[2]))
		elseif info[1] == 'spell' then
			title = GetSpellLink(info[2])
			cooldown = cooldownWrapper(GetSpellCooldown(info[2]))
		end

		if cooldown and cooldown > 2 then -- account for gcd
			-- format the time and gray the item name
			cooldown = '|cffffa500' .. SecondsToTime(cooldown, true, false, false, false) .. '|r'
			title = '|cff999999' .. title:sub(11)

			-- try to automatically select the next available mailbox
			if index == selectedMailbox then
				selectedMailbox = math.min(#MAILBOXES, selectedMailbox + 1)
			end
		else
			cooldown = '|cff00ff00' .. _G.READY .. '|r'
		end

		local prefix = '|TInterface\\Minimap\\POIICONS:12:12:0:400|t' -- empty part of the map
		if index == selectedMailbox then
			prefix = '|A:common-icon-forwardarrow:12:12|a' -- arrow pointing right
		end

		if not title then
			-- no data, try render again next frame
			C_Timer.After(0, updateTooltip)
		else
			GameTooltip:AddDoubleLine(prefix .. title, cooldown)
		end
	end

	-- tutorial
	GameTooltip:AddLine(' ')
	GameTooltip:AddLine('|A:newplayertutorial-icon-mouse-middlebutton:18:14|a to select mailbox', 1, 1, 1)
	GameTooltip:AddLine('|A:newplayertutorial-icon-mouse-leftbutton:18:14|a to summon mailbox', 1, 1, 1)
	GameTooltip:Show()

	return true -- to unregister any event calling this
end

local postCastSucceeded, postCastFailed
do
	function postCastFailed()
		addon:UnregisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player', postCastSucceeded)
		addon:UnregisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED', 'player', postCastFailed)
	end
	function postCastSucceeded()
		addon:RegisterEvent('SPELL_UPDATE_COOLDOWN', updateTooltip)
		addon:UnregisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player', postCastSucceeded)
		addon:UnregisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED', 'player', postCastFailed)
	end
end

mail:SetScript('PreClick', function(self)
	if InCombatLockdown() then
		return
	end

	local mailbox = MAILBOXES[selectedMailbox]
	if mailbox[1] == 'toy' then
		self:SetAttribute('macrotext', '/cast item:' .. mailbox[2])
		addon:RegisterEvent('SPELL_UPDATE_COOLDOWN', updateTooltip)
	elseif mailbox[1] == 'spell' then
		self:SetAttribute('macrotext', '/cast ' .. (GetSpellInfo(mailbox[2])))
	end

	-- update tooltip once a cooldown happens
	addon:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player', postCastSucceeded)
	addon:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED', 'player', postCastFailed)

	-- reset selection
	selectedMailbox = 1
end)

mail:SetScript('OnMouseWheel', function(self, delta)
	if delta > 0 then
		selectedMailbox = math.max(1, selectedMailbox - 1)
	elseif delta < 0 then
		selectedMailbox = math.min(#MAILBOXES, selectedMailbox + 1)
	end

	updateTooltip()
end)

mail:SetScript('OnLeave', GameTooltip_Hide)
mail:SetScript('OnEnter', updateTooltip)

local function updateAvailable()
	-- check which mailboxes the player has
	for index = #MAILBOXES, 1, -1 do
		if MAILBOXES[index][1] == 'toy' and not C_ToyBox.IsToyUsable(MAILBOXES[index][2]) then
			-- might be a caching issue
			if not GetItemInfo(MAILBOXES[index][2]) then
				C_Timer.After(0, updateAvailable)
				return
			end

			table.remove(MAILBOXES, index)
		elseif MAILBOXES[index][1] == 'spell' and not IsSpellKnown(MAILBOXES[index][2]) then
			table.remove(MAILBOXES, index)
		end
	end
end

function addon:PLAYER_LOGIN()
	updateAvailable()
end
