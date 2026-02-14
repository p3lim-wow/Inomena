local _, addon = ...

-- custom buff display

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

local function auraOnUpdate(button)
	if not button.duration then
		return
	end

	local decimals = button.duration:EvaluateRemainingDuration(addon.curves.DurationDecimals)
	button.Time:SetFormattedText('%.' .. decimals .. 'f', button.duration:GetRemainingDuration())
	button.Time:SetAlpha(button.duration:EvaluateRemainingDuration(addon.curves.AuraAlpha))
end

local function auraUpdateBuff(button, auraIndex)
	local unit = button:GetParent():GetAttribute('unit')
	local auraInfo = C_UnitAuras.GetAuraDataByIndex(unit, auraIndex, 'HELPFUL')
	if auraInfo then
		local instanceID = auraInfo.auraInstanceID

		button.Icon:SetTexture(auraInfo.icon)
		button.Count:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(unit, instanceID, 2, 999))

		button.duration = C_UnitAuras.GetAuraDuration(unit, instanceID)
		if button.duration then
			button:SetScript('OnUpdate', auraOnUpdate)
		else
			button:SetScript('OnUpdate', nil)
			button.Time:SetText('')
		end
	end
end

local function auraUpdateEnchant(button, inventorySlotIndex)
	local duration, count, _
	if inventorySlotIndex == 16 then -- main hand
		_, duration, count = GetWeaponEnchantInfo()
	elseif inventorySlotIndex == 17 then -- off hand
		_, _, _, _, _, duration, count = GetWeaponEnchantInfo()
	else
		return
	end

	button.Icon:SetTexture(GetInventoryItemTexture('player', inventorySlotIndex))
	button.Count:SetText(count and count > 1 or '')
	button:SetBorderColor(0.6, 0, 1) -- visual indicator that this is a weapon enchant

	button.duration = C_DurationUtil.CreateDuration()
	button.duration:SetTimeFromStart(GetTime(), duration)
	if button.duration then
		button:SetScript('OnUpdate', auraOnUpdate)
	else
		button:SetScript('OnUpdate', nil)
		button.Time:SetText('')
	end
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
buffs:SetAttribute('sortDirection', '-') -- BUG: https://github.com/Stanzilla/WoWUIBugs/issues/359

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
