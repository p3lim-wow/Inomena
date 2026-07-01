local _, addon = ...

-- skin tooltips

local function getTooltipUnitColor(tooltip)
	-- local _, _, unitGUID = tooltip:GetUnit() -- this is not safe
	local unitGUID = tooltip.processingInfo.tooltipData.guid
	if unitGUID then
		local unit = UnitTokenFromGUID(unitGUID)
		if issecretvalue(unit) then
			local _, classToken = GetPlayerInfoByGUID(unitGUID)
			if classToken ~= nil then
				-- it's a player
				return C_ClassColor.GetClassColor(classToken)
			else
				return tooltip.processingInfo.tooltipData.lines[1].leftColor
			end
		elseif unit ~= nil then
			if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
				local _, classToken = UnitClass(unit)
				return C_ClassColor.GetClassColor(classToken)
			elseif UnitIsMinion(unit) then
				return addon:CreateColor(UnitSelectionColor(unit, true))
			else
				return tooltip.processingInfo.tooltipData.lines[1].leftColor
			end
		end
	end

	return WHITE_FONT_COLOR
end

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

	local r, g, b = getTooltipUnitColor(tooltip):GetRGB()
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
		self:SetStatusBarColor(getTooltipUnitColor(tooltip):GetRGB())
	end

	local function skin(tooltip)
		if tooltip:IsForbidden() then
			return
		end

		if not tooltip.NineSlice or tooltip.IsEmbedded then
			-- not a skinnable tooltip
			return
		end

		if addon:HasBackdrop(tooltip) then
			-- we already skinned it
			return
		end

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

	local lastFrame
	function addon:ADDON_LOADED()
		local frame = EnumerateFrames(lastFrame)
		while frame do
			if frame:GetObjectType() == 'GameTooltip' then
				skin(frame)
			end

			lastFrame = frame
			frame = EnumerateFrames(frame)
		end
	end
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

-- replace money frame on tooltip with string alternative, which we can skin
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.SellPrice, function(tooltip, lineData)
	tooltip:AddLine(SELL_PRICE .. ': ' .. GetMoneyString(lineData.price), WHITE_FONT_COLOR:GetRGB())
	return true
end)
