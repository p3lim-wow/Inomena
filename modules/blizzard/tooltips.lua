local _, addon = ...

-- skin tooltips

-- color unit name
local NAME_REALM_FORMAT = '%s |cff777777(%s)|r'
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local _, _, unitGUID = tooltip:GetUnit() -- is this safe now?
	if not unitGUID then
		return
	end

	local color
	local _, classToken = GetPlayerInfoByGUID(unitGUID)
	if classToken ~= nil then
		-- this works for players, but not for player NPCs (like in follower dungeons),
		-- which is a tradeoff I'm fine with as it's only an issue for raid/party frames
		color = C_ClassColor.GetClassColor(classToken)
	else
		local unit = UnitTokenFromGUID(unitGUID)
		if not issecretvalue(unit) and unit ~= nil then
			if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
				_, classToken = UnitClass(unit)
				color = C_ClassColor.GetClassColor(classToken)
			elseif UnitIsMinion(unit) then
				color = addon:CreateColor(UnitSelectionColor(unit, true))
			end
		end
	end

	local r, g, b = (color or data.leftColor):GetRGB()
	tooltip.StatusBar:SetStatusBarColor(r, g, b)

	local name, realm = UnitNameFromGUID(unitGUID)
	if realm ~= nil then
		tooltip:AddLine(NAME_REALM_FORMAT:format(name, realm), r, g, b)
	elseif name ~= nil then
		tooltip:AddLine(name, r, g, b)
	else
		tooltip:AddLine(data.leftText, r, g, b)
	end

	return true -- we're replacing the line, so prevent the original one from rendering
end)

-- color unit ownership
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitOwner, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	tooltip:AddLine(data.leftText, 1/2, 1/2, 1/2) -- TODO: move to colors
	return true
end)

-- remove some lines
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitThreat, function(tooltip)
	if not tooltip:IsForbidden() then
		return true
	end
end)

-- replace money frame on tooltip with string alternative, which we can skin
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.SellPrice, function(tooltip, lineData)
	tooltip:AddLine(SELL_PRICE .. ': ' .. GetMoneyString(lineData.price), WHITE_FONT_COLOR:GetRGB())
	return true
end)

-- skin tooltips and their health bars
do
	local function tooltipOnShow(self)
		if self.CompareHeader then
			-- slight tint so we can differentiate them easily
			self:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
			self:SetBorderColor(0.2, 0.2, 0.2)
		else
			self:SetBackgroundColor(0, 0, 0, 0.8)
			self:SetBorderColor(0, 0, 0, 1)
		end
	end

	local function tooltipHealthChanged(self)
		local tooltip = self:GetParent()
		self:SetStatusBarColor(tooltip.TextLeft1:GetTextColor())
	end

	function addon:SkinTooltip(tooltip)
		addon:Hide(tooltip, 'NineSlice')
		addon:AddBackdrop(tooltip)

		tooltip:HookScript('OnShow', tooltipOnShow)

		if tooltip.CompareHeader then
			-- hide "Equipped" header
			tooltip.CompareHeader:SetAlpha(0)
		end

		if tooltip.StatusBar then
			tooltip.StatusBar:ClearAllPoints()
			tooltip.StatusBar:SetPoint('BOTTOMLEFT')
			tooltip.StatusBar:SetPoint('BOTTOMRIGHT')
			tooltip.StatusBar:SetHeight(3)
			tooltip.StatusBar:SetStatusBarTexture(addon.TEXTURE)
			tooltip.StatusBar:HookScript('OnValueChanged', tooltipHealthChanged)
		end
	end

	for _, tooltip in next, {
		'GameTooltip',
		'ShoppingTooltip1',
		'ShoppingTooltip2',
		-- 'AddonButtonTooltip', -- forbidden :(
	} do
		addon:SkinTooltip(_G[tooltip])
	end

	addon:SkinTooltip(addon:GetTooltip())
end

-- set custom font
for _, tooltipFontString in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall',
} do
	_G[tooltipFontString]:SetFont(addon.FONT, 12, 'OUTLINE')
	_G[tooltipFontString]:SetShadowOffset(0, 0)
end
