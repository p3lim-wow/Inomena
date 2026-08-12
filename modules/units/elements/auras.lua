local _, addon = ...
local oUF = addon.oUF

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
		showWhenHelpful = (options.showCustomBuffBorder or element.showCustomBuffBorder),
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

local function dispelCallback(element, options)
	element:SetAuraSlotCandidateFilters(options.__key, {
		includeDispelTypes = addon:GetDispelTypes('HARMFUL')
	})
end

function addon.unitShared.CreateDispelOverlay(element, options, button)
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

	local filterCallback = GenerateFlatClosure(dispelCallback, element, options)
	element.__owner:RegisterEvent('SPELLS_CHANGED', filterCallback, true)
	element.__owner:RegisterEvent('PLAYER_LOGIN', filterCallback, true)
end
