local _, addon = ...

-- skin the action bars

local function updateCooldown(button)
	local duration
	if C_ActionBar.HasAction(button.action) then
		local actionType, actionID = GetActionInfo(button.action)
		if actionType == 'item' then
			local startTime, durationSecond = C_Item.GetItemCooldown(actionID)
			if durationSecond > 1.5 then -- GCD
				duration = C_DurationUtil.CreateDuration()
				duration:SetTimeFromStart(startTime, durationSecond)
			end
		else
			-- handles actions, as well as items or spells in macros
			local cooldown = C_ActionBar.GetActionCooldown(button.action)
			if cooldown and not cooldown.isOnGCD then
				duration = C_ActionBar.GetActionCooldownDuration(button.action)
			end
		end
	end

	if duration then
		button.Icon:SetDesaturation(duration:EvaluateRemainingDuration(addon.curves.ActionDesaturation))
		button:SetAlpha(duration:EvaluateRemainingDuration(addon.curves.ActionAlpha))
	else
		button.Icon:SetDesaturation(0)
		button:SetAlpha(1)
	end
end

local function updateIcon(self, texture)
	self.Icon:SetTexture(texture)
end

local function updateIconColor(self, ...)
	self.Icon:SetVertexColor(...)
end

local function showIcon(self)
	self.Icon:SetAlpha(1)
end

local function hideIcon(self)
	self.Icon:SetAlpha(0)
end

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

		-- disable castbars, reticles, interrupts etc, and loss-of-control spiral
		button.enableSpellFX = nil
		button.enableLOCCooldown = nil

		-- need to roll our own icon if we want to desaturate it, in order to prevent taints
		local Icon = button:CreateTexture(nil, 'BORDER')
		Icon:SetPoint('CENTER')
		Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.Icon = Icon

		-- hook original icon for texture updates, bit of an ugly hack
		hooksecurefunc(button.icon, 'SetTexture', updateIcon)
		hooksecurefunc(button.icon, 'SetVertexColor', updateIconColor)
		hooksecurefunc(button.icon, 'Show', showIcon)
		hooksecurefunc(button.icon, 'Hide', hideIcon)
		button.icon.Icon = Icon

		-- set icon size
		if prefix == 'PetActionButton' then
			Icon:SetSize(26, 26)
		else
			Icon:SetSize(42, 42)

			-- reposition and change font of hotkey
			button.HotKey:ClearAllPoints()
			button.HotKey:SetPoint('TOPLEFT', button, 2, -4)
			button.HotKey:SetFont(addon.FONT, 14, 'OUTLINE')
			button.HotKey:SetJustifyH('LEFT')
			button.HotKey:SetIgnoreParentAlpha(true)

			-- rewrite binding text
			hooksecurefunc(button, 'UpdateHotkeys', rewriteHotKeyText)
			rewriteHotKeyText(button)

			-- use desaturation and alpha to indicate cooldowns better
			hooksecurefunc(button, 'UpdateAction', updateCooldown)
			button.cooldown:HookScript('OnCooldownDone', GenerateClosure(updateCooldown, button))
			addon:RegisterEvent('SPELL_UPDATE_COOLDOWN', GenerateClosure(updateCooldown, button))
		end

		-- add backdrop anchored to the icon
		addon:AddBackdrop(button, Icon)
		button:SetBorderIgnoreParentAlpha(true)

		-- hide textures
		button.icon:SetSize(0.001, 0.001) -- prevent taint
		addon:Hide(button, 'Border') -- equipped border
		addon:Hide(button, 'Flash')
		addon:Hide(button, 'NewActionTexture')
		addon:Hide(button, 'SpellHighlightTexture')
		addon:Hide(button, 'SlotBackground')
		addon:Hide(button, 'Name') -- macro name
		button.Name = nil -- prevent secret taint

		-- hide button textures in a different way because they use atlases
		button:GetNormalTexture():SetAlpha(0)
		button:GetPushedTexture():SetAlpha(0)
		button:GetCheckedTexture():SetColorTexture(0, 0, 0, 0)

		-- reposition and change font of count widget
		button.Count:ClearAllPoints()
		button.Count:SetPoint('BOTTOMRIGHT', -2, 2)
		button.Count:SetFont(addon.FONT, 18, 'OUTLINE')
		button.Count:SetJustifyH('RIGHT')

		-- replace highlight texture with color
		local highlight = button:GetHighlightTexture()
		highlight:SetAllPoints(Icon)
		highlight:SetColorTexture(0, 3/5, 1, 1/3)
		highlight:SetBlendMode('ADD')

		-- add custom pushed texture
		local pushed = button:CreateTexture(nil, 'OVERLAY')
		pushed:SetAllPoints(Icon)
		pushed:SetColorTexture(1, 1, 2/5, 1/3)
		pushed:SetBlendMode('ADD')
		pushed:Hide()
		button.Pushed = pushed
		hooksecurefunc(button, 'SetButtonState', updatePushedState)

		-- reanchor cooldown
		button.cooldown:SetAllPoints(Icon)
		button.cooldown:SetHideCountdownNumbers(true)
		button.cooldown:SetIgnoreParentAlpha(true)

		-- adjust style for charge cooldowns
		button.chargeCooldown:SetDrawEdge(false)
		button.chargeCooldown:SetDrawSwipe(true)
		button.chargeCooldown:SetSwipeColor(0, 0, 0, 0.9)
		button.chargeCooldown:SetAllPoints(Icon)
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
