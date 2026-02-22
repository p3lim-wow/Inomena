local _, addon = ...

-- add a repair button to the character frame

local REPAIR_ITEMS = {
	-- sorted in order by ease-of-use, cost, or features
	49040, -- Jeeves (also has bank)
	109644, -- Walter (also has bank, cheap)
	132514, -- Auto-Hammer
	144341, -- Rechargeable Reaves Battery (needs to interact with menu)
	40769, -- Scrapbot Construction Kit
	18232, -- Field Repair Bot 74A
	34113, -- Field Repair Bot 110G
	132523, -- Reaves Battery (single-use and menu)
}

local TEXT_AVERAGE = '|cffffffffAverage:|r %d%%'
local TEXT_LOWEST = '|cffffffffLowest:|r %d%%'
local TEXT_ITEM = '|A:NPE_LeftClick:18:18|a Summon |T%s:14:14|t %s'

local Frame = addon:CreateFrame('Frame', nil, CharacterFrame)
Frame:SetPoint('TOPLEFT', 55, -25)
Frame:SetSize(30, 30)

local Icon = Frame:CreateTexture()
Icon:SetAllPoints()
Icon:SetTexture([[Interface\Cursor\Crosshair\RepairNPC]]) -- has artifacts but it's barely visible

local Button = addon:CreateButton('Button', nil, UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate')
Button:SetAttribute('type1', 'item')
Button:SetPropagateMouseMotion(true)
Button:SetFrameStrata('HIGH') -- render above all else
RegisterStateDriver(Button, 'visibility', '[combat] hide;')

Frame:SetScript('OnEnter', function(self)
	local tooltip = addon:GetTooltip(self, 'ANCHOR_RIGHT')
	tooltip:AddLine(DURABILITY)

	-- get durability info for inventory slots
	local lowest, average, numItems = 1, 0, 0
	for slotIndex in next, INVENTORY_ALERT_STATUS_SLOTS do
		local cur, max = GetInventoryItemDurability(slotIndex)
		if cur ~= nil then
			local percent = cur / max
			if percent < lowest then
				lowest = percent
			end

			average = average + percent
			numItems = numItems + 1
		end
	end

	if numItems > 1 then
		average = average / numItems

		tooltip:AddLine(TEXT_AVERAGE:format(average * 100), addon.curves.Durability:Evaluate(average):GetRGB())
		tooltip:AddLine(TEXT_LOWEST:format(lowest * 100), addon.curves.Durability:Evaluate(lowest):GetRGB())
	end

	local repairItem = Button:GetItem()
	if repairItem then
		Button:SetAllPoints(self)
		Button:SetAttribute('item', 'item:' .. repairItem:GetItemID())
		Button:Show()

		local itemQualityColor = repairItem:GetItemQualityColor()
		local itemNameColored = itemQualityColor.color:WrapTextInColorCode(repairItem:GetItemName())
		tooltip:AddLine(TEXT_ITEM:format(repairItem:GetItemIcon(), itemNameColored))
	end

	tooltip:Show()
end)

Frame:SetScript('OnLeave', function()
	addon:HideTooltip()

	if not InCombatLockdown() then
		Button:Hide()
	end
end)

function Button:GetItem()
	if InCombatLockdown() then
		return
	end

	for _, itemID in next, REPAIR_ITEMS do
		if C_Item.GetItemCount(itemID) > 0 then
			local _, duration = C_Item.GetItemCooldown(itemID)
			if not duration or duration == 0 then
				return Item:CreateFromItemID(itemID)
			end
		end
	end
end
