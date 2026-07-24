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

	self:SetScript('OnEnter', addon.unitShared.ShowTooltip)
	self:SetScript('OnLeave', addon.unitShared.HideTooltip)
	self:RegisterForClicks('AnyUp')
	self:SetSize(320, 30)

	addon.unitShared.AddShiftClick(self, unit)
	addon.unitShared.AddMiddleClick(self)

	local HealthTempLoss = self:CreateBackdropStatusBar()
	HealthTempLoss:SetAllPoints()
	HealthTempLoss:SetReverseFill(true)
	HealthTempLoss:SetStatusBarTexture('UI-HUD-UnitFrame-Target-PortraitOn-Bar-TempHPLoss')

	local Health = self:CreateStatusBar()
	Health:SetPoint('LEFT')
	Health:SetPoint('TOPRIGHT', HealthTempLoss:GetStatusBarTexture(), 'TOPLEFT')
	Health:SetPoint('BOTTOMRIGHT', HealthTempLoss:GetStatusBarTexture(), 'BOTTOMLEFT')
	Health.colorClass = true
	Health.colorReaction = true
	Health.incomingHealOverflow = 1
	Health.TempLoss = HealthTempLoss
	self.Health = Health

	self.HealthPrediction = {}
	self.HealthPrediction.incomingHealOverflow = 1 -- don't let it escape bounds

	local HealingPrediction = Health:CreateStatusBar()
	HealingPrediction:SetPoint('TOP')
	HealingPrediction:SetPoint('BOTTOM')
	HealingPrediction:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	HealingPrediction:SetStatusBarColor(addon.colors.healing:GetRGBA())
	Health.HealingAll = HealingPrediction

	local DamageAbsorb = Health:CreateStatusBar()
	DamageAbsorb:SetPoint('TOP')
	DamageAbsorb:SetPoint('BOTTOM')
	DamageAbsorb:SetPoint('LEFT', HealingPrediction:GetStatusBarTexture(), 'RIGHT')
	DamageAbsorb:SetStatusBarColor(addon.colors.absorb:GetRGB())
	Health.DamageAbsorb = DamageAbsorb

	local HealAbsorb = Health:CreateStatusBar()
	HealAbsorb:SetPoint('TOP')
	HealAbsorb:SetPoint('BOTTOM')
	HealAbsorb:SetPoint('RIGHT', Health:GetStatusBarTexture())
	HealAbsorb:SetWidth(self:GetWidth())
	HealAbsorb:GetStatusBarTexture():SetAtlas('RaidFrame-Absorb-Overlay', false, nil, nil, 'REPEAT', 'REPEAT')
	HealAbsorb:GetStatusBarTexture():SetHorizTile(true)
	HealAbsorb:GetStatusBarTexture():SetVertTile(true)
	HealAbsorb:GetStatusBarTexture():SetVertexColor(0, 0, 0)
	HealAbsorb:SetReverseFill(true)
	Health.HealAbsorb = HealAbsorb

	local HealthValue = self:CreateText()
	HealthValue:SetPoint('RIGHT', -addon.SPACING, 0)
	HealthValue:SetJustifyH('RIGHT')
	self:Tag(HealthValue, '[|cff43ebe7+$>inomena:absorb<$|r ][|cffff8080-$>inomena:hpdef<$|r ][inomena:hpcur][ $>inomena:hpper<$|cff0090ff%|r]')

	-- need to render texts higher than all the healpred stuff
	HealthValue:GetParent():SetFrameLevel(Health:GetFrameLevel() + 5)

	local Status = self:CreateText()
	Status:SetPoint('LEFT', addon.SPACING, 0)
	Status:SetJustifyH('LEFT')
	self:Tag(Status, '[|cffffff00$>group<$|r ][inomena:dead][inomena:resting][inomena:resurrect]')

	if MANA_CLASSES[addon.PLAYER_CLASS] then
		local Power = self:CreateBackdropStatusBar()
		Power:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -addon.SPACING)
		Power:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -addon.SPACING)
		Power:SetHeight(5)
		Power.colorPower = true
		Power.displayAltPower = true -- needed for display override to work
		Power.GetDisplayPower = overrideDisplayPower
		self.Power = Power

		local PowerPrediction = Power:CreateStatusBar()
		PowerPrediction:SetReverseFill(true)
		PowerPrediction:SetPoint('TOP')
		PowerPrediction:SetPoint('BOTTOM')
		PowerPrediction:SetPoint('RIGHT', Power:GetStatusBarTexture())
		PowerPrediction:SetStatusBarColor(0, 0, 0, 0.4) -- render as a shade
		Power.CostPrediction = PowerPrediction
	end

	local Debuffs
	if self.CreateAuras then
		Debuffs = self:CreateAuras({
			growthX = 'LEFT',
			growthY = 'UP', -- default
			initialAnchor = 'BOTTOMRIGHT',
		})
		Debuffs.elementSpacing = addon.SPACING
		Debuffs.lineSpacing = addon.SPACING
		Debuffs.tooltipAnchor = 'ANCHOR_TOPLEFT'
		Debuffs.tooltipOffsetY = 3
		Debuffs.tooltipOffsetX = -1
	else -- TODO: remove in 12.1
		Debuffs = self:CreateFrame()
		Debuffs:SetHeight(self:GetHeight() * 1.5)
		Debuffs.growthX = 'LEFT'
		Debuffs.initialAnchor = 'BOTTOMRIGHT'
		Debuffs.spacing = addon.SPACING
		Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura -- for border colors
		Debuffs.maxCols = 99 -- for nowrap
		Debuffs.PostUpdate = addon.unitShared.PostUpdateAuras -- for nowrap
		self.Debuffs = Debuffs
	end

	Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, addon.SPACING)
	Debuffs.size = self:GetHeight() * 1.2
	Debuffs.CreateButton = addon.unitShared.CreateAura

	if self.CreateAuras then
		Debuffs:AddGroup('HARMFUL')
	else
		-- private auras are merged in the new aura system, so we don't need them in 12.1
		local PrivateAuras = self:CreateFrame()
		PrivateAuras:SetPoint('BOTTOMRIGHT', Debuffs, 'BOTTOMLEFT', 1, 0)
		PrivateAuras:SetSize(self:GetWidth(), Debuffs:GetHeight())
		PrivateAuras.size = Debuffs.size
		PrivateAuras.spacing = Debuffs.spacing
		PrivateAuras.growthX = Debuffs.growthX
		PrivateAuras.initialAnchor = Debuffs.initialAnchor
		PrivateAuras.maxCols = Debuffs.maxCols
		PrivateAuras.borderScale = 2.5
		self.PrivateAuras = PrivateAuras
	end

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', self, 'TOP')
	RaidIcon:SetSize(24, 24)
	self.RaidTargetIndicator = RaidIcon
end)

oUF:SetActiveStyle(styleName)

local player = oUF:Spawn('player')
player:SetPoint('CENTER', -420, -260)
addon:PixelPerfect(player)

-- expose internally
addon.units.player = player
