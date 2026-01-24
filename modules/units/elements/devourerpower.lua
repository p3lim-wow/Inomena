local _, addon = ...
local oUF = addon.oUF

-- this could be in oUF instead, but it's very TBD

local playerClass = UnitClassBase('player')

local SPEC_DEMONHUNTER_DEVOURER = _G.SPEC_DEMONHUNTER_DEVOURER or 3

local function UpdateColor(element, isCollapsing)
	-- local color
	-- TBD

	if element.PostUpdateColor then
		element:PostUpdateColor(--[[color, ]] isCollapsing)
	end
end

local function Update(self, event, unit)
	local element = self.DevourerPower
	if element.PreUpdate then
		element:PreUpdate()
	end

	local cur, max = 0, 0

	local collapsingStar = C_UnitAuras.GetPlayerAuraBySpellID(1227702)
	if collapsingStar then
		cur = collapsingStar.applications
		max = 30
	else
		local voidMetamorphosis = C_UnitAuras.GetPlayerAuraBySpellID(1225789)
		if voidMetamorphosis then
			cur = voidMetamorphosis.applications
			max = C_SpellBook.IsSpellKnown(1247534) and 35 or 50
		end
	end

	if max ~= element.__max then
		element.__max = max
		element:SetMinMaxValues(0, max)

		do
			(element.UpdateColor or UpdateColor) (element, max == 30)
		end
	end

	if cur ~= element.__cur then
		element.__cur = cur
	else
		return
	end

	element:SetValue(cur)

	if element.Text then
		element.Text:SetText(cur)
	end

	if element.PostUpdate then
		element:PostUpdate(cur, max)
	end
end

local function Path(self, ...)
	(self.DevourerPower.Override or Update) (self, ...)
end

local function Visibility(self, ...)
	local element = self.DevourerPower
	local shouldEnable

	if(not UnitHasVehicleUI('player')) then
		if(C_SpecializationInfo.GetSpecialization() == SPEC_DEMONHUNTER_DEVOURER) then
			shouldEnable = true
		end
	end

	local isEnabled = element.__isEnabled

	if(shouldEnable and not isEnabled) then
		self:RegisterEvent('UNIT_AURA', Path)
		element.__isEnabled = true
	elseif(not shouldEnable and isEnabled) then
		self:UnregisterEvent('UNIT_AURA', Path)
		element:Hide()
		element.__isEnabled = false
	elseif(shouldEnable and isEnabled) then
		Path(self, ...)
	end
end

local function VisibilityPath(self, ...)
	(self.DevourerPower.OverrideVisibility or Visibility) (self, ...)
end

local function Disable(self)
	local element = self.DevourerPower
	if element then
		self:UnregisterEvent('UNIT_AURA', Path)
		self:UnregisterEvent('SPELLS_CHANGED', VisibilityPath)
		element:Hide()
	end
end

local function Enable(self, unit)
	local element = self.DevourerPower
	if element then
		if unit ~= 'player' or playerClass ~= 'DEMONHUNTER' then
			Disable(self)
			return false
		end

		element.__owner = self
		self:RegisterEvent('SPELLS_CHANGED', VisibilityPath, true)

		return true
	end
end

oUF:AddElement('DevourerPower', VisibilityPath, Enable, Disable)
