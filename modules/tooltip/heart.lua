-- local r, g, b = ARTIFACT_BAR_COLOR:GetRGB()
local r, g, b = 2/7, 5/7, 1
local VALUE_FORMAT = '%.2f%% (%d / %d)'
GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local _, itemLink = self:GetItem()
	if((GetItemInfoFromHyperlink(itemLink)) == 158075) then
		local itemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		if(itemLocation) then
			local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(itemLocation)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(ARTIFACT_POWER, VALUE_FORMAT:format(cur / max * 100, cur, max), r, g, b, r, g, b)
		end
	end
end)
