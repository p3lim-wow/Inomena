local _, addon = ...
local oUF = addon.oUF

do
	local function onAuraEnter(Button)
		if GameTooltip:IsForbidden() or not Button:IsVisible() then
			return
		end

		local element = Button:GetParent()
		GameTooltip:SetOwner(Button, element.__restricted and 'ANCHOR_CURSOR' or 'ANCHOR_TOPRIGHT')
		GameTooltip:SetUnitAuraByAuraInstanceID(element.__owner.unit, Button.auraInstanceID)
	end

	local function onAuraLeave()
		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end

	function addon.unitShared.CreateAura(element)
		local Button = element:CreateBackdropFrame('Button')
		Button:SetScript('OnEnter', onAuraEnter)
		Button:SetScript('OnLeave', onAuraLeave)

		local Icon = Button:CreateIcon()
		Icon:SetAllPoints()
		Button.Icon = Icon

		local Cooldown = Button:CreateCooldown()
		Cooldown:SetReverse(true)
		Cooldown:SetUseAuraDisplayTime(true) -- no idea what this does
		Button.Cooldown = Cooldown

		if element.disableCooldownText then
			Cooldown:SetHideCountdownNumbers(true)
		else
			Cooldown:ClearTimePoints()
			Cooldown:SetTimePoint('TOPLEFT', 1, -1)
		end

		local Count = Button:CreateText()
		Count:SetPoint('BOTTOMRIGHT', 2, 1)
		Button.Count = Count

		if element.PostCreateButton then
			element:PostCreateButton(Button)
		end

		if element.disableMouse then
			Button:EnableMouse(false)
		end

		return Button
	end
end

function addon.unitShared.PostUpdateAura(element, Button, unit, data)
	-- color by dispel type
	local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, element.dispelColorCurve)
	Button:SetBorderColor((color or oUF.colors.dispel[oUF.Enum.DispelType.None]):GetRGB())
end

function addon.unitShared.PostUpdateAuras(element)
	-- dynamic width based on visible auras
	local spacing = element.spacingX or element.spacing or 0
	local width = element.width or element.size or 16
	element:SetWidth((element.visibleButtons * (width + spacing)) + 1)
end
