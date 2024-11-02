local _, addon = ...

local defaultColor = addon:CreateColor(1, 1, 1)
local lastColor
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, data)
	if tooltip:IsForbidden() then
		return
	end

	if not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local unit = data.unitToken
	if not unit then
		return
	end

	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		if class then
			lastColor = addon.colors.class[class]
		end
	elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
		lastColor = COLOR_TAPPED
	else
		local reactionColor = addon.colors.reaction[UnitReaction(unit, 'player')]
		if reactionColor then
			lastColor = reactionColor
		end
	end

	GameTooltipStatusBar:SetStatusBarColor((lastColor or defaultColor):GetRGB())
end)

-- statusbar position and style
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint('BOTTOMLEFT', GameTooltip)
GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', GameTooltip)
GameTooltipStatusBar:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:HookScript('OnValueChanged', function(self)
	self:SetStatusBarColor((lastColor or defaultColor):GetRGB())
end)

local shade = GameTooltipStatusBar:CreateTexture(nil, 'OVERLAY')
shade:SetAllPoints(GameTooltipStatusBar:GetStatusBarTexture())
shade:SetColorTexture(0, 0, 0, 0.4)

-- borders
addon:AddBackdrop(GameTooltip)
addon:AddBackdrop(GameTooltipStatusBar)
GameTooltip:SetBackgroundColor(0, 0, 0, 0.65)
addon:Hide('GameTooltip', 'NineSlice')

-- font
for _, name in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall', -- shoppingtooltips
} do
	local obj = _G[name]
	obj:SetFont(addon.FONT, 12, 'OUTLINE')
	obj:SetShadowOffset(0, 0)
end

local function resetSize(self)
	local width, height = self:GetSize()
	if width ~= math.floor(width + 0.5) or height ~= math.floor(height + 0.5) then
		self:SetSize(math.floor(width + 0.5), math.floor(height + 0.5))
	end
end

GameTooltip:HookScript('OnShow', resetSize)
GameTooltip:HookScript('OnSizeChanged', resetSize)
GameTooltip:HookScript('OnTooltipSetDefaultAnchor', resetSize)
hooksecurefunc(GameTooltip, 'SetOwner', resetSize)
