local _, addon = ...

-- tracks combat resurrections during encounters and challenges

-- a little bit of flare
local BRES_SPELL = addon.CLASS_RESURRECT_COMBAT_SPELLS[addon.PLAYER_CLASS]
if not BRES_SPELL then
	BRES_SPELL = addon.CLASS_RESURRECT_COMBAT_SPELLS.DRUID
end

local Button = addon:CreateFrame('Frame', nil, UIParent)
Button:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -25, 0) -- same offset as buffs
Button:SetSize(40, 40)
Button:AddBackdrop()
addon:PixelPerfect(Button)
Button:Hide()

local Icon = Button:CreateIcon()
Icon:SetAllPoints()
Icon:SetTexture(C_Spell.GetSpellTexture(BRES_SPELL))

local Cooldown = Button:CreateCooldown()
Cooldown:SetDrawSwipe(true)

local Charges = Button:CreateText(16)
Charges:SetPoint('CENTER', Button, 'TOP')
Charges:SetJustifyH('CENTER')

Button:SetThrottledUpdate(1, function()
	local info = C_Spell.GetSpellCharges(BRES_SPELL)
	if info and info.currentCharges ~= nil then
		if info.currentCharges == 0 then
			Icon:SetDesaturated(true)
			Cooldown:SetDrawEdge(true)
			Cooldown:SetHideCountdownNumbers(false)
			Charges:SetText('')
		else
			Icon:SetDesaturated(false)
			Cooldown:SetDrawEdge(false)
			Cooldown:SetHideCountdownNumbers(true)
			Charges:SetText(info.currentCharges)
		end

		Cooldown:SetCooldown(info.cooldownStartTime, info.cooldownDuration, info.chargeModRate)
	else
		local cooldown = C_Spell.GetSpellCooldown(BRES_SPELL)
		if cooldown and not cooldown.isOnGCD and cooldown.startTime > 1 then
			Icon:SetDesaturated(true)
			Cooldown:SetDrawEdge(false)
			Cooldown:SetHideCountdownNumbers(false)
			Cooldown:SetCooldown(cooldown.startTime, cooldown.duration, cooldown.modRate)
		else
			Icon:SetDesaturated(false)
		end
	end
end)

function addon:ENCOUNTER_START(encounterID)
	Button:Show()
end

function addon:ENCOUNTER_END(encounterID)
	if encounterID and not C_ChallengeMode.IsChallengeModeActive() then
		Button:Hide()
	end
end

function addon:CHALLENGE_MODE_START()
	Button:Show()
end

function addon:CHALLENGE_MODE_COMPLETED()
	Button:Hide()
end

function addon:PLAYER_ENTERING_WORLD()
	if C_ChallengeMode.IsChallengeModeActive() or IsEncounterInProgress() then
		Button:Show()
	end
end
