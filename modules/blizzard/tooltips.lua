local _, addon = ...

-- skin tooltips

-- title and statusbar color
local cachedColor
local function updateColor(self)
	self:SetStatusBarColor((cachedColor or WHITE_FONT_COLOR):GetRGB())
end

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local _, _, guid = tooltip:GetUnit()
	if not guid then
		return
	end

	local _, classToken, _, _, _, name = GetPlayerInfoByGUID(guid)
	if classToken ~= nil then
		data.leftText = name
		data.leftColor = C_ClassColor.GetClassColor(classToken)
	end

	-- broken for follower NPCs, they should preferably be class colored too,
	-- as well as battle pets - they don't trigger UnitName

	cachedColor = data.leftColor
	updateColor(tooltip.StatusBar)
end)

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

	if tooltip.StatusBar then
		tooltip.StatusBar:ClearAllPoints()
		tooltip.StatusBar:SetPoint('BOTTOMLEFT')
		tooltip.StatusBar:SetPoint('BOTTOMRIGHT')
		tooltip.StatusBar:SetHeight(3)
		tooltip.StatusBar:SetStatusBarTexture(addon.TEXTURE)
		tooltip.StatusBar:HookScript('OnValueChanged', updateColor)
	end
end

for _, tooltip in next, {
	'GameTooltip',
	'ShoppingTooltip1',
	'ShoppingTooltip2',
	addon:GetTooltip():GetName(), -- our own tooltip
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

-- set custom font
for _, tooltipFontString in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall',
} do
	_G[tooltipFontString]:SetFont(addon.FONT, 12, 'OUTLINE')
	_G[tooltipFontString]:SetShadowOffset(0, 0)
end
