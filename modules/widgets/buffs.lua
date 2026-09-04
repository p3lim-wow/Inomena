local _, addon = ...

-- custom buff display

local timeOptions = {
	textFormatter = addon.formatters.Countdown
}

local function createButton(button)
	addon:AddBackdrop(button)

	button:SetSize(36, 36)
	button:SetCancelAuraButtons('RightButtonUp')
	button:SetTooltipAnchorPoint('ANCHOR_BOTTOMLEFT', -3, -3)

	local Icon = addon.widgetMixin.CreateIcon(button, 'ARTWORK')
	Icon:SetAllPoints()
	button:SetIcon(Icon)

	local Count = addon.widgetMixin.CreateText(button)
	Count:SetPoint('CENTER', button, 'BOTTOM')
	Count:SetJustifyH('CENTER')
	button:SetApplicationCount(Count)

	local Time = addon.widgetMixin.CreateText(button, 13)
	Time:SetPoint('TOPLEFT', 1, -1)
	Time:SetJustifyH('LEFT')
	button:SetDurationText(Time, timeOptions)
end

local layout = {
	elementSpacing = addon.SPACING,
	lineSpacing = addon.SPACING,
}

local Buffs = CreateFrame('AuraContainer', nil, UIParent, 'CustomAuraContainerTemplate')
Buffs:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -25, 0)
addon:PixelPerfect(Buffs)

Buffs:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal) -- this is the default
Buffs:SetFlowLayoutAnchorPoint('TOPRIGHT')
Buffs:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Down)
Buffs:SetFlowLayoutMaximumLineSize(500) -- fits 12 buffs in a line

local AttributeHandler = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
AttributeHandler:SetScript('OnAttributeChanged', function(self, attribute, value)
	if attribute == 'unit' and Buffs:GetUnit() ~= value then
		Buffs:SetUnit(value)
	end
end)
RegisterAttributeDriver(AttributeHandler, 'unit', '[vehicleui] vehicle; player')

Buffs:SetItemEnchantmentLayout(layout)
Buffs:AddAuraGroup(Buffs:GetDebugName(), 'HELPFUL', {
	initializeFrame = createButton,
	sortMethod = AuraContainerSortMethod.ExpirationOnly,
	sortDirection = AuraContainerSortDirection.Reverse,
	layout = layout,
})

for _, slot in next, AuraContainerItemEnchantmentSlot do
	Buffs:AddItemEnchantment(slot, {
		initializeFrame = function(button)
			createButton(button)
			button:SetBorderColor(0.6, 0, 1)
		end
	})
end
