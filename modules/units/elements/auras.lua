local _, addon = ...
local oUF = addon.oUF

if addon:HasVersion(120100) then
	function addon.unitShared.PostCreateAura(element, button, options)
		Mixin(button, addon.widgetMixin)
		button:AddBackdrop()

		if options.raiseLevels or element.raiseLevels then
			button:SetFrameLevel(element:GetFrameLevel() + (options.raiseLevels or element.raiseLevels))
		end

		addon.widgetMixin.iconMixin.SetDefaultOptions(button.Icon)

		if not (options.disableCooldown or element.disableCooldown) then
			local Cooldown = Mixin(button.Cooldown, addon.widgetMixin.cooldownMixin)
			Cooldown:SetDefaultOptions()
			Cooldown:SetReverse(true)
			Cooldown:SetUseAuraDisplayTime(true) -- still no idea what this does
			Cooldown:SetSwipeColor(0, 0, 0, 0.7) -- adjust our default swipe color, it's too dark
			Cooldown:SetTimeFont(options.cooldownTextSize or element.cooldownTextSize)

			if options.disableCooldownText or element.disableCooldownText then
				Cooldown:SetHideCountdownNumbers(true)
			else
				Cooldown:ClearTimePoints()
				if options.centerCooldownText or element.centerCooldownText then
					Cooldown:SetTimePoint('CENTER')
					Cooldown:SetTimeJustifyH('CENTER')
				else
					Cooldown:SetTimePoint('TOPLEFT', 1, -1)
					Cooldown:SetTimeJustifyH('LEFT')
				end
			end
		end

		if options.showCount or element.showCount then
			local Count = Mixin(button.Count, addon.widgetMixin.textMixin)
			Count:ClearAllPoints() -- probably not necessary
			Count:SetPoint('BOTTOMRIGHT', 2, 1)
			Count:SetDefaultOptions()
			Count:SetSmoothScaling(true) -- for nameplates
		end

		local borderOptions = {
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			showWhenHarmful = not (options.hideDebuffBorder or element.hideDebuffBorder),
			showWhenHelpful = (options.showBuffBorder or element.showBuffBorder),
			customDispelColorMap = element.__owner.colors.dispel,
		}

		-- we have to duplicate our backdrop border because both .showWithoutDispelType and
		-- .showAlways have logical flaws that makes them unusable for this purpose - otherwise
		-- I'd love to just color our existing backdrop edges
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
		BorderBottom:SetTexture(addon.TEXTURE)
		BorderBottom:SetHeight(1)
		button:AddDispelTypeTexture(BorderBottom, borderOptions)

		if options.PostCreateButton then -- NOTE: this was renamed
			options.PostCreateButton(element, button, options)
		end
	end

	function addon.unitShared.CreateDispelOverlay(element, _, button)
		Mixin(button, addon.widgetMixin)

		button:EnableMouse(false)
		button:SetAllPoints(element.__owner) -- cover entire parent
		button:SetFrameLevel(element.__owner:GetFrameLevel() + 20) -- way above everything else

		local DispelGradient = button:CreateTexture('OVERLAY')
		DispelGradient:SetAllPoints()
		DispelGradient:SetTexCoord(0, 1, 0, 1)
		DispelGradient:SetAtlas('_RaidFrame-Dispel-Highlight-Horizontal', false, nil, nil, 'REPEAT', 'CLAMP')
		button:AddDispelTypeTexture(DispelGradient, {
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			customDispelColorMap = element.__owner.colors.dispel,
		})

		local DispelBorder = button:CreateTexture('OVERLAY')
		DispelBorder:SetAllPoints()
		DispelBorder:SetAtlas('RaidFrame-DispelHighlight')
		button:AddDispelTypeTexture(DispelBorder, {
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			customDispelColorMap = element.__owner.colors.dispel,
		})

		local DispelIcon = button:CreateTexture('OVERLAY', 1) -- above the other two
		DispelIcon:SetPoint('CENTER', button, 'TOPRIGHT', -1, -1)
		DispelIcon:SetSize(24, 24)
		button:AddDispelTypeTexture(DispelIcon, {
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
		})
	end
else -- TODO: remove in 12.1
	local function onAuraEnter(Button)
		if not Button:IsVisible() then
			return
		end

		local element = Button:GetParent()
		local anchor = element.__restricted and 'ANCHOR_CURSOR' or 'ANCHOR_TOPRIGHT'
		local tooltip = addon:GetTooltip(Button, anchor)
		if tooltip:SetUnitAuraByAuraInstanceID(element.__owner.__unit, Button.auraInstanceID) then
			tooltip:Show()
		end
	end

	function addon.unitShared.CreateAura(element)
		local button = element:CreateBackdropFrame('Button', 'InsecureMouseMotionPropagatorTemplate,InsecureMouseClicksPropagatorTemplate')
		button:SetScript('OnEnter', onAuraEnter)
		button:SetScript('OnLeave', addon.HideTooltip)

		local Icon = button:CreateIcon()
		Icon:SetAllPoints()
		button.Icon = Icon

		local Cooldown = button:CreateCooldown()
		Cooldown:SetReverse(true)
		Cooldown:SetUseAuraDisplayTime(true) -- still no idea what this does
		Cooldown:SetSwipeColor(0, 0, 0, 0.7) -- adjust our default swipe color, it's too dark
		button.Cooldown = Cooldown

		local CooldownText = Cooldown:GetCountdownFontString()
		CooldownText:SetSmoothScaling(true) -- for nameplates

		if element.cooldownTextSize then
			Cooldown:SetTimeFont(element.cooldownTextSize)
		end

		if element.disableCooldownText then
			Cooldown:SetHideCountdownNumbers(true)
		else
			CooldownText:ClearAllPoints()

			if element.centerCooldownText then
				CooldownText:SetPoint('CENTER')
				CooldownText:SetJustifyH('CENTER')
			else
				CooldownText:SetPoint('TOPLEFT', 1, -1)
				CooldownText:SetJustifyH('LEFT')
			end
		end

		local Count = button:CreateText()
		Count:SetPoint('BOTTOMRIGHT', 2, 1)
		Count:SetSmoothScaling(true) -- for nameplates
		button.Count = Count

		if element.PostCreateButton then
			element:PostCreateButton(button)
		end

		return button
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
end
