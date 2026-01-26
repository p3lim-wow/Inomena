local _, addon = ...

-- skin the cooldown manager
-- works best with icon size <= 60% and padding = 9

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
end

for _, group in next, {
	'EssentialCooldownViewer',
	'UtilityCooldownViewer',
	'BuffIconCooldownViewer',
} do
	hooksecurefunc(_G[group], 'OnAcquireItemFrame', GenerateClosure(skin, group))
end
