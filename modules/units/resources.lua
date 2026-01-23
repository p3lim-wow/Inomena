local _, addon = ...
local oUF = addon.oUF

local PLAYER_CLASS = addon.PLAYER_CLASS
local PLAYER_SPECS = addon.enums.ClassSpecializations[PLAYER_CLASS]

local function overrideDisplayPower(_, unit)
	-- basically never show mana
	if UnitHasVehicleUI(unit) then
		return (UnitPowerType('vehicle'))
	else
		local spec = C_SpecializationInfo.GetSpecialization()
		if PLAYER_CLASS == 'DEATHKNIGHT' then
			return Enum.PowerType.RunicPower
		elseif PLAYER_CLASS == 'DEMONHUNTER' then
			return Enum.PowerType.Fury
		elseif PLAYER_CLASS == 'DRUID' then
			local form = GetShapeshiftFormID()
			if form == addon.enums.DruidForms.Cat then
				return Enum.PowerType.Energy
			elseif form == addon.enums.DruidForms.Bear then
				return Enum.PowerType.Rage
			elseif spec == PLAYER_SPECS.Balance then
				return Enum.PowerType.LunarPower
			end
		elseif PLAYER_CLASS == 'HUNTER' then
			return Enum.PowerType.Focus
		elseif PLAYER_CLASS == 'MAGE' and spec == PLAYER_SPECS.Arcane then
			return Enum.PowerType.Mana -- it's a rotational important resource for this spec
		elseif PLAYER_CLASS == 'MONK' and spec ~= PLAYER_SPECS.Mistweaver then
			return Enum.PowerType.Energy
		elseif PLAYER_CLASS == 'PRIEST' and spec == PLAYER_SPECS.Shadow then
			return Enum.PowerType.Insanity
		elseif PLAYER_CLASS == 'ROGUE' then
			return Enum.PowerType.Energy
		elseif PLAYER_CLASS == 'SHAMAN' and spec == PLAYER_SPECS.Elemental then
			return Enum.PowerType.Maelstrom
		elseif PLAYER_CLASS == 'WARRIOR' then
			return Enum.PowerType.Rage
		end
	end
end

local function postUpdatePower(element, unit)
	-- hide power if player is idle
	local shouldShow = false
	if element.displayType then
		shouldShow = true

		if InCombatLockdown() then
			element:SetAlpha(1)
		else
			local alphaCurve = addon.curves.PowerIdleAlpha[element.displayType]
			element:SetAlpha(UnitPowerPercent(unit, nil, true, alphaCurve))
		end
	end

	element:SetShown(shouldShow)
end

local function wrapForceUpdate(self)
	self.Power:ForceUpdate()

	if self:IsElementEnabled('Runes') then
		self.Runes:ForceUpdate()
	end
end

local function updateChargedComboPoint(element, ...)
	-- reset first
	for index = 1, 10 do
		element[index]:Hide()
	end

	if ... then
		for index = 1, select('#', ...) do
			element[(select(index, ...))]:Show()
		end
	end
end


local function postUpdateClassPower(element, _, max, maxChanged, _, ...)
	if maxChanged then -- need to resize each class power bar
		addon:ResizePillsToFit(element, max)
	end

	updateChargedComboPoint(element.ChargedComboPoints, ...) -- handler for custom sub-widget
end

local styleName = addon.unitPrefix .. 'Resources'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	self:SetSize(310, 1)
	self:EnableMouse(false) -- non-interactable

	local Power = self:CreateBackdropStatusBar()
	Power:SetPoint('BOTTOMLEFT')
	Power:SetPoint('BOTTOMRIGHT')
	Power:SetHeight(12)
	Power.colorPower = true
	Power.colorPowerAtlas = addon.PLAYER_COLOR ~= 'HUNTER' -- focus atlas looks horrible
	Power.frequentUpdates = true
	Power.displayAltPower = true -- needed for display override to work
	Power.GetDisplayPower = overrideDisplayPower
	Power.PostUpdate = postUpdatePower
	self.Power = Power

	local PowerValue = Power:CreateText()
	PowerValue:SetPoint('CENTER')
	self:Tag(PowerValue, '[inomena:power]')

	local ClassPower = self:CreateFrame()
	ClassPower:SetPoint('BOTTOMLEFT', Power, 'TOPLEFT', 0, addon.SPACING)
	ClassPower:SetPoint('BOTTOMRIGHT', Power, 'TOPRIGHT', 0, addon.SPACING)
	ClassPower:SetHeight(12)
	ClassPower.PostUpdate = postUpdateClassPower
	ClassPower.ChargedComboPoints = {}
	self.ClassPower = ClassPower

	for index = 1, 10 do
		local ClassPowerBar = ClassPower:CreateBackdropStatusBar()
		ClassPowerBar:SetHeight(ClassPower:GetHeight())
		ClassPower[index] = ClassPowerBar

		if index == 1 then
			ClassPowerBar:SetPoint('LEFT')
		else
			ClassPowerBar:SetPoint('LEFT', ClassPower[index - 1], 'RIGHT', addon.SPACING, 0)
		end

		-- charged combo points, which oUF doesn't support directly
		local ChargedComboPoint = ClassPower:CreateBackdropStatusBar()
		ChargedComboPoint:SetPoint('BOTTOMLEFT', ClassPowerBar, 8, -2)
		ChargedComboPoint:SetPoint('BOTTOMRIGHT', ClassPowerBar, -8, -2)
		ChargedComboPoint:SetHeight(6)
		ChargedComboPoint:SetValue(1) -- we never update this widget
		ChargedComboPoint:SetStatusBarColor(self.colors.power.MANA:GetRGB()) -- close enough
		ChargedComboPoint:SetFrameLevel(ClassPowerBar:GetFrameLevel() + 1)
		ChargedComboPoint:Hide()
		ClassPower.ChargedComboPoints[index] = ChargedComboPoint
	end

	local Runes = self:CreateFrame()
	Runes:SetPoint('BOTTOMLEFT', Power, 'TOPLEFT', 0, addon.SPACING)
	Runes:SetPoint('BOTTOMRIGHT', Power, 'TOPRIGHT', 0, addon.SPACING)
	Runes:SetHeight(12)
	Runes.colorSpec = true
	self.Runes = Runes

	for index = 1, 6 do
		local Rune = Runes:CreateBackdropStatusBar()
		Rune:SetHeight(Runes:GetHeight())
		Rune:SetWidth((self:GetWidth() - (5 * addon.SPACING)) / 6)
		Runes[index] = Rune

		if index == 1 then
			Rune:SetPoint('LEFT')
		else
			Rune:SetPoint('LEFT', Runes[index - 1], 'RIGHT', addon.SPACING, 0)
		end
	end

	-- we need to register combat state events to update visibility
	self:RegisterEvent('PLAYER_REGEN_ENABLED', wrapForceUpdate, true)
	self:RegisterEvent('PLAYER_REGEN_DISABLED', wrapForceUpdate, true)
end)

oUF:SetActiveStyle(styleName)

-- hide whenever in pet battle (which is the default), or when skyriding
local parent = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
RegisterStateDriver(parent, 'visibility', '[petbattle][bonusbar:5] hide; show')

local resources = oUF:Spawn('player')
resources:SetPoint('BOTTOM', UIParent, 'CENTER', 0, -300)
resources:SetParent(parent)
addon:PixelPerfect(resources)

-- expose internally
addon.units.resources = resources
