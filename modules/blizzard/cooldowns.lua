local _, addon = ...

-- skin the cooldown manager
-- works best with icon size <= 60% and padding = 9

local function updateCooldown(button, _, spellID, baseSpellID)
	local cooldownInfo = button:GetCooldownInfo()
	if not cooldownInfo then
		return
	end

	-- (try to) ensure whatever triggered this call was meant for this button
	if not spellID then
		-- for when this function was triggered by something anonymous we just gotta update,
		-- which sadly is true for SPELL_UPDATE_CHARGES, SPELL_UPDATE_USABLE
		spellID = (cooldownInfo.overrideSpellID or cooldownInfo.spellID)
	elseif (cooldownInfo.overrideSpellID or cooldownInfo.spellID) == baseSpellID then
		spellID = baseSpellID
	elseif (cooldownInfo.overrideSpellID or cooldownInfo.spellID) ~= spellID then
		return
	end

	local duration
	local charge = C_Spell.GetSpellChargeDuration(spellID)
	local cooldown = C_Spell.GetSpellCooldown(spellID)
	if cooldown and not cooldown.isOnGCD then
		duration = C_Spell.GetSpellCooldownDuration(spellID)
	end

	button.CustomCooldown:Hide()
	button.Icon:SetDesaturation(0)
	button:SetAlpha(1)

	if charge or duration then
		button.CustomCooldown:SetCooldownFromDurationObject(charge or duration)

		if duration then
			button.Icon:SetDesaturation(duration:EvaluateRemainingDuration(addon.curves.ActionDesaturation))
			button:SetAlpha(duration:EvaluateRemainingDuration(addon.curves.ActionAlpha))
		end
	end
end

local skinned = {}
local function skin(group, _, button)
	if skinned[button] then
		return
	else
		skinned[button] = true
	end

	-- add backdrop
	addon:PixelPerfect(button)
	addon:AddBackdrop(button)
	button:SetBorderIgnoreParentAlpha(true)

	-- change texture size and bounds
	button.Icon:SetAllPoints()
	button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.Icon:RemoveMaskTexture(button.Icon:GetMaskTexture(1))

	-- hide overlay texture
	for _, child in next, {button:GetRegions()} do
		if child.GetAtlas and child:GetAtlas() == 'UI-HUD-CoolDownManager-IconOverlay' then
			child:SetAlpha(0)
		end
	end

	if button.DebuffBorder then
		-- hide this border until we know what to do with it
		button.DebuffBorder:SetAlpha(0)
	end

	-- make cooldown animations ignore parent alpha
	if button.CooldownFlash then
		button.CooldownFlash:SetIgnoreParentAlpha(true)
	end

	-- re-anchor and change font of charges
	if button.ChargeCount then
		button.ChargeCount.Current:ClearAllPoints()
		button.ChargeCount.Current:SetPoint('CENTER', button.Icon, 'TOP')
		button.ChargeCount.Current:SetFont(addon.FONT, 18, 'OUTLINE')
	end

	-- re-anchor and change font of applications
	if button.Applications then
		button.Applications.Applications:ClearAllPoints()
		button.Applications.Applications:SetPoint('CENTER', button.Icon, 'TOP')
		button.Applications.Applications:SetFont(addon.FONT, 24, 'OUTLINE')
	end

	if button.RefreshSpellCooldownInfo then
		-- remove the default cooldown widget as it also tracks buff/debuff uptime
		addon:Hide(button, 'Cooldown')

		-- add custom cooldown widget
		button.CustomCooldown = addon:CreateCooldown(button)
		button.CustomCooldown:SetIgnoreParentAlpha(true)
		button.CustomCooldown:SetIgnoreGlobalCooldown(true)
		button.CustomCooldown:SetCountdownAbbrevThreshold(59)
		button.CustomCooldown:SetSwipeColor(0, 0, 0, 0.7)
		button.CustomCooldown:SetTimeFont(group == 'EssentialCooldownViewer' and 20 or 14)
		addon:RegisterEvent('SPELL_UPDATE_COOLDOWN', GenerateClosure(updateCooldown, button))
		addon:RegisterEvent('SPELL_UPDATE_USABLE', GenerateFlatClosure(updateCooldown, button))

		-- instead of registering for SPELL_UPDATE_CHARGES, which is anonymous, we check for
		-- charges once the main cooldown is done, but this renders isEnabled=false as if they're
		-- permanently on a full duration cooldown (which is better than the current bug where the
		-- cooldown spiral "strobes" in and out of cooldown state)
		button.CustomCooldown:HookScript('OnCooldownDone', GenerateFlatClosure(updateCooldown, button))

		-- prevent CDM from messing with desaturation
		-- we also use this to initiate cooldowns on login
		hooksecurefunc(button.Icon, 'SetDesaturated', GenerateFlatClosure(updateCooldown, button))
	else -- buff viewer
		-- re-anchor existing cooldown widget and adjust swipe texture
		button.Cooldown:SetAllPoints(button.Icon)
		button.Cooldown:SetSwipeTexture(addon.TEXTURE)
		button.Cooldown:SetIgnoreParentAlpha(true)
	end
end

for _, group in next, {
	'EssentialCooldownViewer',
	'UtilityCooldownViewer',
	'BuffIconCooldownViewer',
} do
	-- hide whenever in pet battle, vehicle, or when skyriding
	local listener = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
	RegisterStateDriver(listener, 'visibility', '[petbattle][vehicleui][bonusbar:5] hide; show')
	listener:HookScript('OnAttributeChanged', function(_, _, shouldHide)
		_G[group]:SetAlphaFromBoolean(not shouldHide, 1, 0)
		for _, button in next, _G[group]:GetItemFrames() do
			if button.SetBorderIgnoreParentAlpha then -- not ready yet
				button:SetBorderIgnoreParentAlpha(not shouldHide)
			end
		end
	end)

	hooksecurefunc(_G[group], 'OnAcquireItemFrame', GenerateClosure(skin, group))
end
