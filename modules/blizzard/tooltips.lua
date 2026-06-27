local _, addon = ...

-- skin tooltips

-- name and statusbar color
local cachedColor
local function updateColor(self)
	self:SetStatusBarColor((cachedColor or WHITE_FONT_COLOR):GetRGB())
end

local NAME_REALM_FORMAT = '%s |cff777777(%s)|r'
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local guid = tooltip.processingInfo.tooltipData.guid
	if not guid then
		return
	end

	local unit = UnitTokenFromGUID(guid)

	local name, realm
	if issecretvalue(unit) then
		local _, classToken = GetPlayerInfoByGUID(guid)
		name, realm = UnitNameFromGUID(guid)

		if classToken ~= nil then
			cachedColor = C_ClassColor.GetClassColor(classToken)
		else
			cachedColor = data.leftColor
		end
	elseif unit ~= nil then
		if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
			local _, classToken = UnitClass(unit)
			cachedColor = C_ClassColor.GetClassColor(classToken)

			-- grab name from GUID regardless so we can avoid realm name
			name, realm = UnitNameFromGUID(guid)
		elseif UnitIsMinion(unit) then
			-- TODO: this is a bit wasteful, pre-create the colors and use the other API
			cachedColor = addon:CreateColor(UnitSelectionColor(unit, true))
		else
			cachedColor = data.leftColor
		end
	end

	updateColor(tooltip.StatusBar)

	if realm ~= nil then
		tooltip:AddLine(NAME_REALM_FORMAT:format(name, realm), cachedColor:GetRGB())
	elseif name ~= nil then
		tooltip:AddLine(name, cachedColor:GetRGB())
	else
		tooltip:AddLine(data.leftText, (cachedColor or data.leftColor):GetRGB())
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

-- replace border
local function skin(tooltip)
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

local lastFrame
function addon:ADDON_LOADED()
	lastFrame = EnumerateFrames()
	while lastFrame do
		if lastFrame:GetObjectType() == 'GameTooltip' then
			skin(lastFrame)
		end

		lastFrame = EnumerateFrames(lastFrame)
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
