local _, addon = ...

-- skin the (used/visible) action bars

local function updatePushedState(button, state)
	button.Pushed:SetShown(state == 'PUSHED')
end

local function rewriteHotKeyText(button)
	local text = button.HotKey:GetText() or ''
	text = text:upper()
	text = text:gsub(' ', '')
	text = text:gsub('%-', '')
	text = text:gsub('MOUSEBUTTON', 'M')
	text = text:gsub('MIDDLEMOUSE', 'MM')
	text = text:gsub(RANGE_INDICATOR, '')
	button.HotKey:SetText(text)
end

for prefix, numButtons in next, {
	ActionButton = 12,
	MultiBarBottomLeftButton = 12,
	MultiBarBottomRightButton = 12,
	MultiBarLeftButton = 12,
	MultiBarRightButton = 12,
	MultiBar5Button = 12,
	MultiBar6Button = 12,
	MultiBar7Button = 12,
	PetActionButton = 10,
} do
	for index = 1, numButtons do
		local button = _G[prefix .. index]

		-- resize icon
		if prefix == 'PetActionButton' then
			button.icon:SetSize(26, 26)
		else
			button.icon:SetSize(42, 42)
		end

		-- add backdrop anchored to the icon
		addon:AddBackdrop(button, button.icon)

		-- hide textures
		addon:Hide(button, 'Border') -- equipped border
		addon:Hide(button, 'Name') -- macro name
		addon:Hide(button, 'Flash')
		addon:Hide(button, 'NewActionTexture')
		addon:Hide(button, 'SpellHighlightTexture')
		addon:Hide(button, 'SlotBackground')

		-- hide button textures in a different way because they use atlases
		button:GetNormalTexture():SetAlpha(0)
		button:GetPushedTexture():SetAlpha(0)
		button:GetCheckedTexture():SetColorTexture(0, 0, 0, 0)

		-- change texture size and bounds
		button.icon:ClearAllPoints()
		button.icon:SetPoint('CENTER')
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon:RemoveMaskTexture(button.IconMask)
		button.icon:SetDrawLayer('BORDER')

		if prefix ~= 'PetActionButton' then
			-- reposition and change font of hotkey
			button.HotKey:ClearAllPoints()
			button.HotKey:SetPoint('TOPLEFT', button, 2, -4)
			button.HotKey:SetFont(addon.FONT, 14, 'OUTLINE')
			button.HotKey:SetJustifyH('LEFT')

			-- rewrite binding text
			hooksecurefunc(button, 'UpdateHotkeys', rewriteHotKeyText)
			rewriteHotKeyText(button)
		end

		-- reposition and change font of count widget
		button.Count:ClearAllPoints()
		button.Count:SetPoint('BOTTOMRIGHT', -2, 2)
		button.Count:SetFont(addon.FONT, 18, 'OUTLINE')
		button.Count:SetJustifyH('RIGHT')

		-- replace highlight texture with color
		local highlight = button:GetHighlightTexture()
		highlight:SetAllPoints(button.icon)
		highlight:SetColorTexture(0, 3/5, 1, 1/3)
		highlight:SetBlendMode('ADD')

		-- add custom pushed texture
		local pushed = button:CreateTexture(nil, 'OVERLAY')
		pushed:SetAllPoints(button.icon)
		pushed:SetColorTexture(1, 1, 2/5, 1/3)
		pushed:SetBlendMode('ADD')
		pushed:Hide()
		button.Pushed = pushed
		hooksecurefunc(button, 'SetButtonState', updatePushedState)

		-- reanchor cooldown
		button.cooldown:SetAllPoints(button.icon)

		-- adjust style for charge cooldowns
		button.chargeCooldown:SetDrawEdge(false)
		button.chargeCooldown:SetDrawSwipe(true)
		button.chargeCooldown:SetSwipeColor(0, 0, 0, 0.9)
		button.chargeCooldown:SetAllPoints(button.icon)
	end
end

-- adjust border color of pet actions based on state
hooksecurefunc(PetActionBar, 'Update', function(self)
	for index = 1, 10 do
		local _, _, _, isActive, _, isAutoCast = GetPetActionInfo(index)
		if isActive or isAutoCast then
			_G['PetActionButton' .. index]:SetBorderColor(1, 1, 0)
		else
			_G['PetActionButton' .. index]:SetBorderColor(0, 0, 0)
		end
	end
end)
