local _, addon = ...

-- summon a repair bot by clicking the icon on the minimap
local ITEMS = {
	[49040] = true, -- Jeeves
	[144341] = true, -- Rechargeable Reaves Battery
}

local function getCooldownRemaining(start, duration)
	return start > 0 and start - GetTime() + duration
end

local function getRepairItem()
	for itemID in next, ITEMS do
		if GetItemCount(itemID) > 0 and not getCooldownRemaining(GetItemCooldown(itemID)) then
			return itemID
		end
	end
end

local repair = addon:CreateButton('RepairButton', Minimap, 'SecureActionButtonTemplate')
repair:SetPoint('BOTTOMRIGHT')
repair:SetSize(33, 33)
repair:SetAttribute('type', 'macro')
repair:SetScript('PreClick', function(self)
	if InCombatLockdown() then
		return
	end

	local itemID = getRepairItem()
	if itemID then
		self:SetAttribute('macrotext', '/cast item:' .. itemID)
	end
end)

repair:SetScript('PostClick', function(self)
	if InCombatLockdown() then
		return
	end

	self:SetAttribute('macrotext', nil)
end)

local damagedAvg, damagedMin
repair:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')

	GameTooltip:AddLine('Durability')
	if damagedAvg < 1 then
		GameTooltip:AddLine(string.format('Average: %d%%', damagedAvg * 100), 1, 1, 1)
	end
	if damagedMin < 1 then
		GameTooltip:AddLine(string.format('Lowest: %d%%', damagedMin * 100), 1, 1, 1)
	end

	if getRepairItem() then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine('Click to summon a repair bot', 1, 1, 1)
	end

	GameTooltip:Show()
end)

repair:SetScript('OnLeave', GameTooltip_Hide)

local icon = repair:CreateTexture(nil, 'OVERLAY')
icon:SetPoint('CENTER')
icon:SetAtlas('repair', true)
icon:SetScale(0.75)

function addon:UPDATE_INVENTORY_DURABILITY()
	local numItems, totalDurability = 0, 0
	damagedMin = 1

	local alert = 0
	for slotIndex in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(slotIndex)
		if status > alert then
			alert = status
		end

		local cur, max = GetInventoryItemDurability(slotIndex)
		if cur ~= nil then
			local avg = cur / max
			if avg < damagedMin then
				damagedMin = avg
			end

			totalDurability = totalDurability + avg
			numItems = numItems + 1
		end
	end

	damagedAvg = totalDurability / numItems

	if INVENTORY_ALERT_COLORS[alert] then
		icon:SetAlpha(1)
	else
		icon:SetAlpha(0)
	end
end
