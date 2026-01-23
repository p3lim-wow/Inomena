local _, addon = ...

-- skyriding vigor and cooldowns

local VIGOR_SPELL = 372610
local THRILL_SPELL = 377234

local SKYRIDING_COOLDOWN_SPELLS = {
	425782, -- Second Wind
	361584, -- Whirling Surge
}

local numVigor = 0

local parent = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
parent:Hide()
addon:PixelPerfect(parent)

local cooldowns = addon:CreateFrame('Frame', nil, parent)
cooldowns:SetPoint('BOTTOMLEFT', addon.units.resources)
cooldowns:SetPoint('BOTTOMRIGHT', addon.units.resources)
cooldowns:SetHeight(12) -- same as the resources
cooldowns.Update = function()
	local cooldownsChanged
	for index, spellID in next, SKYRIDING_COOLDOWN_SPELLS do
		local pill = cooldowns[index]
		if not pill then
			pill = cooldowns:CreateBackdropStatusBar()
			pill:SetHeight(cooldowns:GetHeight())
			pill:SetStatusBarColor(0.7, 0.7, 1)
			cooldowns[index] = pill

			if index == 1 then
				pill:SetPoint('LEFT')
			else
				pill:SetPoint('LEFT', cooldowns[index - 1], 'RIGHT', addon.SPACING, 0)
			end

			local text = pill:CreateText()
			text:SetPoint('CENTER', pill, 'BOTTOM')
			pill.text = text

			cooldownsChanged = true
		end

		local charges = C_Spell.GetSpellCharges(spellID)
		if charges then
			pill.text:SetText(charges.currentCharges)
		end

		if charges and charges.currentCharges > 0 then
			local duration = C_Spell.GetSpellChargeDuration(spellID)
			if duration and not duration:IsZero() then
				pill:SetTimerDuration(duration)
			else
				pill:SetMinMaxValues(0, 1)
				pill:SetValue(1)
			end
		else
			local duration = C_Spell.GetSpellCooldownDuration(spellID)
			if duration and not duration:IsZero() then
				pill:SetTimerDuration(duration)
			else
				pill:SetMinMaxValues(0, 1)
				pill:SetValue(1)
			end
		end
	end

	if cooldownsChanged then
		addon:ResizePillsToFit(cooldowns, #SKYRIDING_COOLDOWN_SPELLS)
	end
end

local vigor = addon:CreateFrame('Frame', nil, parent)
vigor:SetPoint('BOTTOMLEFT', cooldowns, 'TOPLEFT', 0, addon.SPACING)
vigor:SetPoint('BOTTOMRIGHT', cooldowns, 'TOPRIGHT', 0, addon.SPACING)
vigor:SetHeight(12) -- same as the resources
vigor.Update = function()
	local charges = C_Spell.GetSpellCharges(VIGOR_SPELL)
	if charges then
		for index = 1, charges.maxCharges do
			local pill = vigor[index]
			if not pill then
				pill = vigor:CreateBackdropStatusBar()
				pill:SetHeight(vigor:GetHeight())
				vigor[index] = pill

				if index == 1 then
					pill:SetPoint('LEFT')
				else
					pill:SetPoint('LEFT', vigor[index - 1], 'RIGHT', addon.SPACING, 0)
				end
			end

			if charges.currentCharges >= index then
				pill:SetMinMaxValues(0, 1)
				pill:SetValue(1)
			elseif charges.currentCharges + 1 == index then
				local duration = C_Spell.GetSpellChargeDuration(VIGOR_SPELL)
				if duration then
					pill:SetTimerDuration(duration)
				end
			else
				pill:SetMinMaxValues(0, 1)
				pill:SetValue(0)
			end
		end

		if numVigor ~= charges.maxCharges then
			numVigor = charges.maxCharges
			addon:ResizePillsToFit(vigor, numVigor)
		end
	end
end
vigor.UpdateColor = function()
	local color
	if C_UnitAuras.GetUnitAuraBySpellID('player', THRILL_SPELL, 'HELPFUL') then
		color = addon.colors.skyriding.thrill
	else
		color = addon.colors.skyriding.normal
	end

	for index = 1, numVigor do
		vigor[index]:SetStatusBarColor(color:GetRGB())
	end
end

local speed = vigor:CreateText()
speed:SetPoint('BOTTOM', vigor, 'TOP')
speed.Update = function()
	local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
	if isGliding then
		speed:SetFormattedText('%d%%', forwardSpeed / BASE_MOVEMENT_SPEED * 100 + 0.5)
	else
		speed:SetText('')
	end
end

local speedTicker
parent:HookScript('OnShow', function()
	vigor:RegisterEvent('SPELL_UPDATE_CHARGES', vigor.Update)
	vigor:RegisterUnitEvent('UNIT_AURA', 'player', vigor.UpdateColor)
	cooldowns:RegisterEvent('SPELL_UPDATE_COOLDOWN', cooldowns.Update)
	cooldowns:RegisterEvent('SPELL_UPDATE_CHARGES', cooldowns.Update)

	speedTicker = C_Timer.NewTicker(0.05, speed.Update)

	vigor:Update()
	vigor:UpdateColor()
	cooldowns:Update()
end)

parent:HookScript('OnHide', function()
	vigor:UnregisterEvent('SPELL_UPDATE_CHARGES', vigor.Update)
	vigor:UnregisterUnitEvent('UNIT_AURA', 'player', vigor.UpdateColor)
	cooldowns:UnregisterEvent('SPELL_UPDATE_COOLDOWN', cooldowns.Update)
	cooldowns:UnregisterEvent('SPELL_UPDATE_CHARGES', cooldowns.Update)

	if speedTicker then
		speedTicker:Cancel()
	end
end)

-- register state driver late so we trigger the show/hide script handlers
RegisterStateDriver(parent, 'visibility', '[bonusbar:5] show; hide')
