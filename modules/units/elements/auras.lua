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
			Mixin(button, addon.widgetMixin)
			button:AddBackdrop()

			local width = options.width or options.size or element.width or element.size or 16
			local height = options.height or options.size or element.height or element.size or 16
			button:SetSize(width, height)
			button:EnableMouse(not (options.disableMouse or element.disableMouse))

		else
			options = nil
			button = element:CreateBackdropFrame('Button', 'InsecureMouseMotionPropagatorTemplate,InsecureMouseClicksPropagatorTemplate')
			button:SetScript('OnEnter', onAuraEnter)
			button:SetScript('OnLeave', addon.HideTooltip)
		end

		if (options and options.raiseLevels) or element.raiseLevels then
			button:SetFrameLevel(element:GetFrameLevel() + ((options and options.raiseLevels) or element.raiseLevels))
		end

		local Icon = button:CreateIcon()
		Icon:SetAllPoints()
		if AURAPOCALYPSE then
			button:SetIcon(Icon)
		else
			button.Icon = Icon
		end

		local Cooldown = button:CreateCooldown()
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
			local borderOptions = {
				style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
				showWhenHarmful = not (options.hideDebuffBorder or element.hideDebuffBorder),
				showWhenHelpful = (options.showBuffBorder or element.showBuffBorder),
				customDispelColorMap = element.__owner.colors.dispel,
			}

			local BorderLeft = button:CreateTexture('BORDER', 1) -- above the backdrop border
			BorderLeft:SetPoint('TOPLEFT', button, -1, 1)
			BorderLeft:SetPoint('BOTTOMLEFT', button, -1, -1)
			BorderLeft:SetTexture(addon.TEXTURE)
			BorderLeft:SetWidth(1)
			button:AddDispelTypeTexture(BorderLeft, borderOptions)

			local BorderRight = button:CreateTexture('BORDER', 1) -- above the backdrop border
			BorderRight:SetPoint('TOPRIGHT', button, 1, 1)
			BorderRight:SetPoint('BOTTOMRIGHT', button, 1, -1)
			BorderRight:SetTexture(addon.TEXTURE)
			BorderRight:SetWidth(1)
			button:AddDispelTypeTexture(BorderRight, borderOptions)

			local BorderTop = button:CreateTexture('BORDER', 1) -- above the backdrop border
			BorderTop:SetPoint('TOPLEFT', button, -1, 1)
			BorderTop:SetPoint('TOPRIGHT', button, 1, 1)
			BorderTop:SetTexture(addon.TEXTURE)
			BorderTop:SetHeight(1)
			button:AddDispelTypeTexture(BorderTop, borderOptions)

			local BorderBottom = button:CreateTexture('BORDER', 1) -- above the backdrop border
			BorderBottom:SetPoint('BOTTOMLEFT', -1, -1)
			BorderBottom:SetPoint('BOTTOMRIGHT', 1, -1)
			BorderBottom:SetHeight(1)
			BorderBottom:SetTexture(addon.TEXTURE)
			button:AddDispelTypeTexture(BorderBottom, borderOptions)

			if options.showDebuffIcon or element.showDebuffIcon then
				local DispelIcon = button:CreateTexture('ARTWORK', 1) -- above the icon
				DispelIcon:SetPoint('CENTER', button, 'TOP', 0, -1)
				DispelIcon:SetSize(18, 18)
				button:AddDispelTypeTexture(DispelIcon, {
					style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
					showWhenHarmful = true,
				})
			end
		end

		local Count = button:CreateText()
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
