local _, addon = ...

-- add repair info to the character frame

local TEXT_AVERAGE = '|cffffffffAverage:|r %d%%'
local TEXT_LOWEST = '|cffffffffLowest:|r %d%%'

local Frame = addon:CreateFrame('Frame', nil, CharacterFrame)
Frame:SetPoint('TOPLEFT', 55, -25)
Frame:SetSize(30, 30)

local Icon = Frame:CreateTexture()
Icon:SetAllPoints()
Icon:SetTexture([[Interface\Cursor\Crosshair\RepairNPC]]) -- has artifacts but it's barely visible

Frame:SetScript('OnLeave', addon.HideTooltip)
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

	tooltip:Show()
end)
