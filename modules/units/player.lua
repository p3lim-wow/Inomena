local _, addon = ...
local oUF = addon.oUF

local MANA_CLASSES = {
	DRUID = true,
	MAGE = true,
	PALADIN = true,
	PRIEST = true,
	SHAMAN = true,
	MONK = true,
	EVOKER = true,
	WARLOCK = true,
}

local function overrideDisplayPower()
	-- we only show mana
	return Enum.PowerType.Mana
end

local styleName = addon.unitPrefix .. 'Player'
oUF:RegisterStyle(styleName, function(self, unit)
	Mixin(self, addon.widgetMixin)

	self:SetScript('OnEnter', addon.unitShared.Tooltip)
	self:SetScript('OnLeave', GameTooltip_Hide)
	self:RegisterForClicks('AnyUp')
	self:SetSize(320, 30)

	addon.unitShared.AddShiftClick(self, unit)
	addon.unitShared.AddMiddleClick(self)

	local HealthTempLoss = self:CreateBackdropStatusBar()
	HealthTempLoss:SetAllPoints()
	HealthTempLoss:SetReverseFill(true)

	local Health = self:CreateStatusBar()
	Health:SetPoint('LEFT')
	Health:SetPoint('TOPRIGHT', HealthTempLoss:GetStatusBarTexture(), 'TOPLEFT')
	Health:SetPoint('BOTTOMRIGHT', HealthTempLoss:GetStatusBarTexture(), 'BOTTOMLEFT')
	Health.colorClass = true
	Health.colorReaction = true
	Health.TempLoss = HealthTempLoss
	self.Health = Health

	local HealthValue = Health:CreateText()
	HealthValue:SetPoint('RIGHT', -addon.SPACING, 0)
	HealthValue:SetJustifyH('RIGHT')
	self:Tag(HealthValue, '[|cff43ebe7+$>inomena:absorb<$|r ][|cffff8080-$>inomena:hpdef<$|r ][inomena:hpcur][ $>inomena:hpper<$|cff0090ff%|r]')

	local Status = Health:CreateText()
	Status:SetPoint('LEFT', addon.SPACING, 0)
	Status:SetJustifyH('LEFT')
	self:Tag(Status, '[|cffffff00$>group<$|r ][inomena:dead][inomena:resting][inomena:resurrect]')

	self.HealthPrediction = {}
	self.HealthPrediction.incomingHealOverflow = 1 -- don't let it escape bounds

	local HealingPrediction = Health:CreateStatusBar()
	HealingPrediction:SetPoint('TOP')
	HealingPrediction:SetPoint('BOTTOM')
	HealingPrediction:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	HealingPrediction:SetStatusBarColor(140/255, 1, 46/255, 0.5)
	self.HealthPrediction.healingAll = HealingPrediction

	local DamageAbsorb = Health:CreateStatusBar()
	DamageAbsorb:SetPoint('TOP')
	DamageAbsorb:SetPoint('BOTTOM')
	DamageAbsorb:SetPoint('LEFT', HealingPrediction:GetStatusBarTexture(), 'RIGHT')
	DamageAbsorb:SetWidth(self:GetWidth())
	DamageAbsorb:SetStatusBarColor(67/255, 235/255, 231/255)
	self.HealthPrediction.damageAbsorb = DamageAbsorb

	local HealAbsorb = Health:CreateStatusBar()
	HealAbsorb:SetPoint('TOP')
	HealAbsorb:SetPoint('BOTTOM')
	HealAbsorb:SetPoint('RIGHT', Health:GetStatusBarTexture())
	HealAbsorb:SetWidth(self:GetWidth())
	HealAbsorb:SetReverseFill(true)
	HealAbsorb:SetStatusBarColor(251/255, 125/255, 129/255, 0.5)
	self.HealthPrediction.healAbsorb = HealAbsorb

	if MANA_CLASSES[addon.PLAYER_CLASS] then
		local Power = self:CreateBackdropStatusBar()
		Power:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -addon.SPACING)
		Power:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -addon.SPACING)
		Power:SetHeight(5)
		Power.colorPower = true
		Power.displayAltPower = true -- needed for display override to work
		Power.GetDisplayPower = overrideDisplayPower
		self.Power = Power
	end

	local Debuffs = self:CreateFrame()
	Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, addon.SPACING)
	Debuffs:SetHeight(self:GetHeight() * 1.5)
	Debuffs.growthX = 'LEFT'
	Debuffs.initialAnchor = 'BOTTOMRIGHT'
	Debuffs.size = self:GetHeight() * 1.2
	Debuffs.spacing = addon.SPACING
	Debuffs.maxCols = 99 -- make sure it never wraps
	Debuffs.CreateButton = addon.unitShared.CreateAura
	Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	Debuffs.PostUpdate = addon.unitShared.PostUpdateAuras
	self.Debuffs = Debuffs

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP')
	RaidIcon:SetSize(24, 24)
	self.RaidTargetIndicator = RaidIcon
end)

oUF:SetActiveStyle(styleName)

local player = oUF:Spawn('player')
player:SetPoint('CENTER', -420, -260)
addon:PixelPerfect(player)

-- expose internally
addon.units.player = player
