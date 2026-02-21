local _, addon = ...

-- skin tooltips

-- name and statusbar color
local cachedColor
local function updateColor(self)
	self:SetStatusBarColor((cachedColor or WHITE_FONT_COLOR):GetRGB())
end

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local _, unit, guid = tooltip:GetUnit()
	if not guid then
		return
	end

	local name
	if unit ~= nil and issecretvalue(unit) then
		local _, classToken, _, _, _, playerName = GetPlayerInfoByGUID(guid)
		name = playerName

		if classToken ~= nil then
			cachedColor = C_ClassColor.GetClassColor(classToken)
		else
			cachedColor = data.leftColor
		end
	else
		if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
			local _, classToken = UnitClass(unit)
			cachedColor = C_ClassColor.GetClassColor(classToken)

			-- grab name from GUID regardless so we can avoid realm name
			name = UnitNameFromGUID(guid)
		else
			cachedColor = data.leftColor
		end
	end

	updateColor(tooltip.StatusBar)

	if name ~= nil then
		tooltip:AddLine(name, cachedColor:GetRGB())
	else
		tooltip:AddLine(data.leftText, cachedColor:GetRGB())
	end

	return true -- we're replacing the line, so prevent the original one from rendering
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
