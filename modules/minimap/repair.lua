local addonName, addon = ...

local repair = addon:CreateButton('Button', addonName .. 'RepairButton', Minimap, 'SecureActionButtonTemplate')
repair:SetPoint('BOTTOMRIGHT', -7, 7)
repair:SetSize(30, 30)
repair:SetAttribute('type', 'macro')

local icon = repair:CreateTexture('$parentIcon', 'OVERLAY')
icon:SetPoint('CENTER')
icon:SetAtlas('repair', true)
icon:SetScale(0.8)

local function getDurability()
	local lowest = 1
	local averagePercentage = 0

	local numItems = 0
	for slotIndex in next, INVENTORY_ALERT_STATUS_SLOTS do
		local cur, max = GetInventoryItemDurability(slotIndex)
		if cur ~= nil then
			local perc = cur / max
			if perc < lowest then
				lowest = perc
			end

			averagePercentage = averagePercentage + perc
			numItems = numItems + 1
		end
	end

	if numItems > 1 then
		averagePercentage = averagePercentage / numItems
	else
		-- player is naked, no point in returning truthy
		averagePercentage = 1
	end

	return averagePercentage, lowest
end

-- show icon if durability is low
function addon:UPDATE_INVENTORY_DURABILITY()
	local _, lowest = getDurability()
	icon:SetAlpha(lowest < 0.2 and 1 or 0)
end

-- create an API for summonable repair vendors
local REPAIR_SUMMON = {
	49040, -- Jeeves
	144341, -- Rechargeable Reaves Battery
}

local function getCooldownRemaining(start, duration)
	return start > 0 and start - GetTime() + duration
end

local function getRepairSummon()
	for _, itemID in next, REPAIR_SUMMON do
		if GetItemCount(itemID) > 0 and not getCooldownRemaining(GetItemCooldown(itemID)) then
			return itemID
		end
	end
end

-- summon mailbox on click
repair:SetScript('PreClick', function(self)
	if InCombatLockdown() then
		-- can't modify attributes in combat
		return
	end

	local itemID = getRepairSummon()
	if itemID then
		self:SetAttribute('macrotext', '/cast item:' .. itemID)
	end
end)

-- add tooltip
repair:SetScript('OnLeave', GameTooltip_Hide)
repair:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
	GameTooltip:AddLine(DURABILITY)

	-- add detailed durability info
	local average, lowest = getDurability()
	if average and average < 1 then
		GameTooltip:AddLine(string.format('Average: %d%%', average * 100), 1, 1, 1)
	end
	if lowest and lowest < 1 then
		GameTooltip:AddLine(string.format('Lowest: %d%%', lowest * 100), 1, 1, 1)
	end

	if getRepairSummon() then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine('Click to summon a repair bot', 1, 1, 1)
	end

	GameTooltip:Show()
end)
