local _, addon = ...

local function dispelCallback(element, includePlayerOnly)
	-- we only want this overlay for debuffs the player can dispel
	element:SetAuraSlotCandidateFilters(element.slotKey, {
		includeDispelTypes = addon:GetDispelTypes('HARMFUL', includePlayerOnly)
	})
end

local function createButton(element, _, button)
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

function addon.unitShared.CreateDispelOverlay(frame, includePlayerOnly)
	local DispelOverlay = frame:CreateAuras()
	DispelOverlay.slotKey = DispelOverlay:AddSlot('HARMFUL', {
		CreateButton = createButton
	})

	-- adjust candidate filters whenever the player spells change, and on load
	local filterCallback = GenerateFlatClosure(dispelCallback, DispelOverlay, includePlayerOnly)
	frame:RegisterEvent('SPELLS_CHANGED', filterCallback, true)
	filterCallback()
end
