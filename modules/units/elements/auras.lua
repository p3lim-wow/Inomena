local _, addon = ...
local oUF = addon.oUF

do
	local function onAuraEnter(Button) -- TODO: remove in 12.1
		if not Button:IsVisible() then
			return
		end

		local element = Button:GetParent()
		local anchor = element.__restricted and 'ANCHOR_CURSOR' or 'ANCHOR_TOPRIGHT'
		local tooltip = addon:GetTooltip(Button, anchor)
		if tooltip:SetUnitAuraByAuraInstanceID(element.__owner.unit, Button.auraInstanceID) then
			tooltip:Show()
		end
	end

	local AURAPOCALYPSE = addon:HasVersion(120100)
	function addon.unitShared.CreateAura(element, options, button)
		if AURAPOCALYPSE then
			addon:AddBackdrop(button)

			local width = options.width or options.size or element.width or element.size or 16
			local height = options.height or options.size or element.height or element.size or 16
			button:SetSize(width, height)
		else
			options = nil
			button = element:CreateBackdropFrame('Button', 'InsecureMouseMotionPropagatorTemplate,InsecureMouseClicksPropagatorTemplate')
			button:SetScript('OnEnter', onAuraEnter)
			button:SetScript('OnLeave', addon.HideTooltip)
		end

		if (options and options.raiseLevels) or element.raiseLevels then
			button:SetFrameLevel(element:GetFrameLevel() + ((options and options.raiseLevels) or element.raiseLevels))
		end

		local Icon = addon.widgetMixin.CreateIcon(button)
		Icon:SetAllPoints()
		if AURAPOCALYPSE then
			button:SetIcon(Icon)
		else
			button.Icon = Icon
		end

		local Cooldown = addon.widgetMixin.CreateCooldown(button)
		Cooldown:SetReverse(true)
		Cooldown:SetUseAuraDisplayTime(true) -- still no idea what this does
		Cooldown:SetSwipeColor(0, 0, 0, 0.7) -- adjust our default swipe color, it's too dark

		local CooldownText = Cooldown:GetCountdownFontString()
		CooldownText:SetSmoothScaling(true) -- for nameplates

		if (options and options.cooldownTextSize) or element.cooldownTextSize then
			Cooldown:SetTimeFont((options and options.cooldownTextSize) or element.cooldownTextSize)
		end

		if (options and options.disableCooldownText) or element.disableCooldownText then
			Cooldown:SetHideCountdownNumbers(true)
		else
			CooldownText:ClearAllPoints()

			if (options and options.centerCooldownText) or element.centerCooldownText then
				CooldownText:SetPoint('CENTER')
				CooldownText:SetJustifyH('CENTER')
			else
				CooldownText:SetPoint('TOPLEFT', 1, -1)
				CooldownText:SetJustifyH('LEFT')
			end
		end

		if AURAPOCALYPSE then
			button:SetDurationCooldown(Cooldown)
		else
			button.Cooldown = Cooldown
		end

		if AURAPOCALYPSE then
			-- SetAuraBorder only supports _one_ texture, and it doesn't allow a default/None color,
			-- so we need to keep our default backdrop border and overlay a new backdrop texture :(

			local borderOptions = {
				style = AuraButtonBorderStyle.Color,
				showIcon = false,
				showWhenHarmful = not (options.hideDebuffBorder or element.hideDebuffBorder),
				showWhenHelpful = (options.showBuffBorder or element.showBuffBorder),
				customDispelColorMap = element.__owner.colors.dispel,
			}

			local Border = addon.widgetMixin.CreateTexture(button, 'BORDER', 1) -- above the backdrop border
			Border:SetPoint('TOPLEFT', -1, 1)
			Border:SetPoint('BOTTOMRIGHT', 1, -1)
			Border:SetTexture(addon.TEXTURE) -- it needs to be an actual texture
			button:SetAuraBorder(Border, borderOptions)
		end

		local Count = addon.widgetMixin.CreateText(button)
		Count:SetPoint('BOTTOMRIGHT', 2, 1)
		Count:SetSmoothScaling(true) -- for nameplates
		if AURAPOCALYPSE then
			button:SetApplicationCount(Count) -- TODO: add a custom formatter once it's been fixed
		else
			button.Count = Count
		end

		if AURAPOCALYPSE and (options.cancelButton or element.cancelButton) then
			button:SetCancelAuraButtons(options.cancelButton or element.cancelButton)
		end

		if element.disableMouse then
			button:EnableMouse(false)
		end

		if AURAPOCALYPSE and options.postCreateButton then
			options.postCreateButton(element, button, options)
		end

		if element.PostCreateButton then
			element:PostCreateButton(button, options)
		end

		if not AURAPOCALYPSE then
			return button
		end
	end
end

function addon.unitShared.PostUpdateAura(element, Button, unit, data) -- TODO: remove in 12.1
	-- color by dispel type
	local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, element.dispelColorCurve)
	Button:SetBorderColor((color or oUF.colors.dispel[oUF.Enum.DispelType.None]):GetRGB())
end

function addon.unitShared.PostUpdateAuras(element) -- TODO: remove in 12.1
	-- dynamic width based on visible auras
	local spacing = element.spacingX or element.spacing or 0
	local width = element.width or element.size or 16
	element:SetWidth((element.visibleButtons * (width + spacing)) + 1)
end
