local _, addon = ...

-- skin the cooldown manager
-- works best with icon size <= 60% and padding = 9

local function updateCooldown(button)
	local duration, charge
	local spellID = button:GetSpellID()
	if spellID then
		charge = C_Spell.GetSpellChargeDuration(spellID)

		local cooldown = C_Spell.GetSpellCooldown(spellID)
		if cooldown and not cooldown.isOnGCD then
			duration = C_Spell.GetSpellCooldownDuration(spellID)
		end
	end

	if charge or duration then
		button.CustomCooldown.duration = charge or duration
		button.CustomCooldown:SetCooldownFromDurationObject(charge or duration)

		if duration then
			button.Icon:SetDesaturation(duration:EvaluateRemainingDuration(addon.curves.ActionDesaturation))
			button:SetAlpha(duration:EvaluateRemainingDuration(addon.curves.ActionAlpha))
			return
		end
	end

	button.Icon:SetDesaturation(0)
	button:SetAlpha(1)
end

local function updateCooldownTime(cooldown)
	if cooldown.duration then
		local decimals = cooldown.duration:EvaluateRemainingDuration(addon.curves.DurationDecimals)
		cooldown.Time:SetFormattedText('%.' .. decimals .. 'f', cooldown.duration:GetRemainingDuration())
		cooldown.Time:SetAlpha(cooldown.duration:EvaluateRemainingDuration(addon.curves.AuraAlpha))
	end
end

local function updateCooldownIcon(icon)
	updateCooldown(icon:GetParent())
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
		button.Applications.Applications:SetFont(addon.FONT, 14, 'OUTLINE')
	end

	if button.RefreshSpellCooldownInfo then
		-- remove the default cooldown widget as it also tracks buff/debuff uptime
		addon:Hide(button, 'Cooldown')

		-- prevent CDM from messing with desaturation
		hooksecurefunc(button.Icon, 'SetDesaturated', updateCooldownIcon) -- can't just noop it, that taints

		-- add custom cooldown widget
		button.CustomCooldown = addon:CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
		button.CustomCooldown:SetAllPoints()
		button.CustomCooldown:SetHideCountdownNumbers(true)
		button.CustomCooldown:SetIgnoreParentAlpha(true)
		button.CustomCooldown:SetDrawEdge(false)
		button.CustomCooldown:SetDrawBling(false)
		button.CustomCooldown:SetSwipeColor(0, 0, 0, 0.9)

		-- add cooldown time to the widget
		button.CustomCooldown.Time = button.CustomCooldown:CreateText(group == 'EssentialCooldownViewer' and 20 or 14)
		button.CustomCooldown.Time:SetPoint('CENTER')
		button.CustomCooldown.Time:SetJustifyH('CENTER')
		button.CustomCooldown:Hide()
		button.CustomCooldown:SetScript('OnUpdate', updateCooldownTime)

		-- update cooldowns whenever CDM would normally
		hooksecurefunc(button, 'RefreshSpellCooldownInfo', updateCooldown)
		hooksecurefunc(button, 'RefreshSpellChargeInfo', updateCooldown)
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
	hooksecurefunc(_G[group], 'OnAcquireItemFrame', GenerateClosure(skin, group))
end
