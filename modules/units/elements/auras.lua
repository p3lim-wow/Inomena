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

		local Cooldown = Button:CreateFrame('Cooldown', 'CooldownFrameTemplate')
		Cooldown:SetAllPoints()
		Cooldown:SetHideCountdownNumbers(true) -- we want full control over this
		Cooldown:SetReverse(true)
		Cooldown:SetDrawEdge(false)
		Cooldown:SetSwipeColor(0, 0, 0, 0.9)
		Button.Cooldown = Cooldown

		local Count = Button:CreateText()
		Count:SetPoint('BOTTOMRIGHT', 2, 1)
		Button.Count = Count

		local Time = Button:CreateText()
		Time:SetPoint('TOPLEFT', 1, -1)
		Button.Time = Time

		if element.PostCreateButton then
			element:PostCreateButton(Button)
		end

		if element.disableMouse then
			Button:EnableMouse(false)
		end

		return Button
	end
end

do
	local function updateAuraDuration(Button)
		if Button.duration then
			-- show time with a variable amount of decimals
			local decimals = Button.duration:EvaluateRemainingDuration(addon.curves.DurationDecimals)
			Button.Time:SetFormattedText('%.' .. decimals .. 'f', Button.duration:GetRemainingDuration())

			-- show/hide time based on alpha
			Button.Time:SetAlpha(Button.duration:EvaluateRemainingDuration(addon.curves.AuraAlpha))
		end
	end

	function addon.unitShared.PostUpdateAura(element, Button, unit, data)
		-- add custom time display
		if not element.disableCooldownText then
			Button.duration = C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID)
			if Button.duration then
				Button:SetScript('OnUpdate', updateAuraDuration)
			else
				Button:SetScript('OnUpdate', nil)
				Button.Time:SetText('')
			end
		end

		-- color by dispel type
		local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, element.dispelColorCurve)
		if color == nil then
			color = oUF.colors.dispel[oUF.Enum.DispelType.None]
		end
		Button:SetBorderColor(color:GetRGB())
	end
end

function addon.unitShared.PostUpdateAuras(element)
	-- dynamic width based on visible auras
	local spacing = element.spacingX or element.spacing or 0
	local width = element.width or element.size or 16
	element:SetWidth((element.visibleButtons * (width + spacing)) + 1)
end
