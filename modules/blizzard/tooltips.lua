local _, addon = ...

-- skin tooltips

-- replace border
for _, name in next, {
	'GameTooltip',
	'ShoppingTooltip1',
	'ShoppingTooltip2',
} do
	addon:Hide(name, 'NineSlice')
	addon:AddBackdrop(_G[name])

	if _G[name].CompareHeader then
		-- adjust color so it's less confusing
		_G[name]:SetBorderColor(0.2, 0.2, 0.2)
		_G[name]:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)

		-- hide "Equipped" header
		_G[name].CompareHeader:SetAlpha(0)
	else
		_G[name]:SetBackgroundColor(0, 0, 0, 0.8)
	end
end

-- adjust spacing between shopping tooltips
hooksecurefunc(TooltipComparisonManager, 'AnchorShoppingTooltips', function(show1, show2)
	if show1 then
		if ShoppingTooltip1:GetPoint(2) == 'LEFT' then
			ShoppingTooltip1:SetPointsOffset(5, 0)
		else
			ShoppingTooltip1:SetPointsOffset(-5, 0)
		end
	end
	if show2 then
		if ShoppingTooltip2:GetPoint(2) == 'LEFT' then
			ShoppingTooltip2:SetPointsOffset(5, 0)
		else
			ShoppingTooltip2:SetPointsOffset(-5, 0)
		end
	end
end)

-- set custom font
for _, name in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall',
} do
	_G[name]:SetFont(addon.FONT, 12, 'OUTLINE')
	_G[name]:SetShadowOffset(0, 0)
end

-- style bar
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint('BOTTOMLEFT')
GameTooltipStatusBar:SetPoint('BOTTOMRIGHT')
GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:SetStatusBarTexture(addon.TEXTURE)
