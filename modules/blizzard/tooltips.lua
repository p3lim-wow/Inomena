local _, addon = ...

-- skin tooltips

-- replace border
local function skin(tooltipName)
	local tooltip = _G[tooltipName]
	addon:Hide(tooltip, 'NineSlice')
	addon:AddBackdrop(tooltip)

	if tooltip.CompareHeader then
		-- adjust color so it's less confusing
		tooltip:SetBorderColor(0.2, 0.2, 0.2)
		tooltip:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)

		-- hide "Equipped" header
		tooltip.CompareHeader:SetAlpha(0)
	else
		tooltip:SetBackgroundColor(0, 0, 0, 0.8) -- it's too transparent by default
	end
end

for _, tooltip in next, {
	'GameTooltip',
	'ShoppingTooltip1',
	'ShoppingTooltip2',
} do
	skin(tooltip)
end

addon:HookAddOn('OPie', function()
	skin('NotGameTooltip1') -- OPie uses a custom tooltip based on GameTooltip
end)
addon:HookAddOn('TomTom', function()
	skin('TomTomTooltip') -- TomTom uses a custom tooltip too
end)
addon:HookAddOn('InteractiveWormholes', function()
	skin('InteractiveWormholesTooltip')
end)

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
for _, tooltipFontString in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall',
} do
	_G[tooltipFontString]:SetFont(addon.FONT, 12, 'OUTLINE')
	_G[tooltipFontString]:SetShadowOffset(0, 0)
end

-- style bar
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint('BOTTOMLEFT')
GameTooltipStatusBar:SetPoint('BOTTOMRIGHT')
GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:SetStatusBarTexture(addon.TEXTURE)
