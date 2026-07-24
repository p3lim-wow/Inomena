local _, addon = ...

-- custom buff display

if addon:HasVersion(120100) then
	local binding = C_DurationUtil.CreateDurationTextBinding()
	binding:SetFormatter(addon.formatters.Countdown)
	binding:SetExpiredText('')
	binding:SetZeroDurationText('')

	local timeOptions = {
		binding = binding
	}

	local function createButton(button)
		addon:AddBackdrop(button)

		button:SetSize(36, 36)
		button:SetCancelAuraButtons('RightButtonUp')

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

	local enchantmentOptions = {
		initializeFrame = function(button)
			createButton(button)
			button:SetBorderColor(0.6, 0, 1)
		end
	}

	Buffs:AddItemEnchantment(AuraContainerItemEnchantmentSlot.MainHand, enchantmentOptions)
	Buffs:AddItemEnchantment(AuraContainerItemEnchantmentSlot.OffHand, enchantmentOptions)
else
	local function auraOnEnter(button)
		local tooltip = addon:GetTooltip(button, 'ANCHOR_BOTTOMLEFT')

		local auraIndex = button:GetAttribute('index')
		if auraIndex then
			local unit = button:GetParent():GetAttribute('unit')
			if tooltip:SetUnitAura(unit, auraIndex, 'HELPFUL') then
				tooltip:Show()
			end
		elseif button:GetAttribute('target-slot') then
			if tooltip:SetInventoryItem('player', button:GetID()) then
				tooltip:Show()
			end
		end
	end

	local function auraUpdateBuff(button, auraIndex)
		local unit = button:GetParent():GetAttribute('unit')
		local auraInfo = C_UnitAuras.GetAuraDataByIndex(unit, auraIndex, 'HELPFUL')
		if auraInfo then
			local instanceID = auraInfo.auraInstanceID

			button.Icon:SetTexture(auraInfo.icon)
			button.Count:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(unit, instanceID, 2, 999))
			button.Time.Binding:SetDuration(C_UnitAuras.GetAuraDuration(unit, instanceID))
		end
	end

	local function auraUpdateEnchant(button, inventorySlotIndex)
		local expiration, count, _
		if inventorySlotIndex == 16 then -- main hand
			_, expiration, count = GetWeaponEnchantInfo()
		elseif inventorySlotIndex == 17 then -- off hand
			_, _, _, _, _, expiration, count = GetWeaponEnchantInfo()
		else
			return
		end

		button.Icon:SetTexture(GetInventoryItemTexture('player', inventorySlotIndex))
		button.Count:SetText(count and count > 1 or '')
		button:SetBorderColor(0.6, 0, 1) -- visual indicator that this is a weapon enchant

		local duration = C_DurationUtil.CreateDuration()
		duration:SetTimeFromStart(GetTime(), expiration)
		button.Time.Binding:SetDuration(duration)
	end

	local function auraOnAttributeChanged(button, attribute, ...)
		if attribute == 'index' then
			auraUpdateBuff(button, ...)
		elseif attribute == 'target-slot' then
			auraUpdateEnchant(button, ...)
		end
	end

	local function auraButtonInit(button)
		-- inject mixins
		Mixin(button, addon.widgetMixin)

		-- add backdrop
		button:AddBackdrop()

		-- add widgets
		button.Icon = button:CreateIcon()
		button.Icon:SetAllPoints()

		button.Count = button:CreateText()
		button.Count:SetPoint('CENTER', button, 'BOTTOM')
		button.Count:SetJustifyH('CENTER')

		button.Time = button:CreateText(13)
		button.Time:SetPoint('TOPLEFT', 1, -1)
		button.Time:SetJustifyH('LEFT')

		local timeBinding = C_DurationUtil.CreateDurationTextBinding()
		timeBinding:SetFontString(button.Time)
		timeBinding:SetFormatter(addon.formatters.Buff)
		timeBinding:Enable()
		button.Time.Binding = timeBinding

		-- add script handlers
		button:HookScript('OnAttributeChanged', auraOnAttributeChanged)
		button:SetScript('OnEnter', auraOnEnter)
		button:SetScript('OnLeave', addon.HideTooltip)
	end

	local buffs = CreateFrame('Frame', nil, UIParent, 'SecureAuraHeaderTemplate')
	buffs:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -25, 0)
	addon:PixelPerfect(buffs)

	-- set up templates and filters
	buffs:SetAttribute('template', 'SecureAuraButtonTemplate')
	buffs:SetAttribute('unit', 'player')
	buffs:SetAttribute('filter', 'HELPFUL')
	buffs:SetAttribute('includeWeapons', 1)
	buffs:SetAttribute('weaponTemplate', 'SecureAuraButtonTemplate')

	-- sorting
	buffs:SetAttribute('sortMethod', 'TIME')
	buffs:SetAttribute('sortDirection', '-')

	-- position and size for aura buttons
	buffs:SetAttribute('point', 'TOPRIGHT')
	buffs:SetAttribute('minWidth', 510)
	buffs:SetAttribute('minHeight', 210)
	buffs:SetAttribute('xOffset', -42)
	buffs:SetAttribute('wrapYOffset', -42)
	buffs:SetAttribute('wrapAfter', 12)
	buffs:SetAttribute('initialConfigFunction', [[
		-- SetSize is not supported here
		self:SetWidth(36)
		self:SetHeight(36)
	]])

	-- register attribute driver to set unit attribute, with support for vehicles
	RegisterAttributeDriver(buffs, 'unit', '[vehicleui] vehicle; player')

	-- hook attribute changes so we can skin aura buttons
	buffs:HookScript('OnAttributeChanged', function(self, attribute, ...)
		if attribute:match('^child%d+$') or attribute:match('^tempenchant%d$') then
			auraButtonInit(...)
		end
	end)

	-- render header late
	buffs:Show() -- it's hidden by default
end
