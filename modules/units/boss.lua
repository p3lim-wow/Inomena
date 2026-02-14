local _, addon = ...
local oUF = addon.oUF

local function filterBuffs(_, unit)
	return UnitIsEnemy('player', unit)
end

local styleName = addon.unitPrefix .. 'Boss'
oUF:RegisterStyle(styleName, function(self, unit)
	Mixin(self, addon.widgetMixin)

	self:SetScript('OnEnter', addon.unitShared.ShowTooltip)
	self:SetScript('OnLeave', addon.unitShared.HideTooltip)
	self:RegisterForClicks('AnyUp')
	self:SetSize(250, 30)

	addon.unitShared.AddShiftClick(self, unit)
	addon.unitShared.AddMiddleClick(self)

	local Health = self:CreateBackdropStatusBar()
	Health:SetPoint('TOPLEFT')
	Health:SetPoint('TOPRIGHT')
	Health:SetHeight(24)
	Health.colorReaction = true -- we only set these so oUF registers events
	Health.colorSelection = true
	Health.UpdateColor = addon.unitShared.UpdateColorHealth
	self.Health = Health

	self.HealthPrediction = {}

	local DamageAbsorb = Health:CreateStatusBar()
	DamageAbsorb:SetPoint('TOP')
	DamageAbsorb:SetPoint('BOTTOM')
	DamageAbsorb:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	DamageAbsorb:SetStatusBarColor(67/255, 235/255, 231/255)
	Health.DamageAbsorb = DamageAbsorb

	local HealthValue = Health:CreateText()
	HealthValue:SetPoint('RIGHT', -addon.SPACING, 0)
	HealthValue:SetJustifyH('RIGHT')
	self:Tag(HealthValue, '[inomena:hpper<$|cff0090ff%|r]')

	-- need to render texts higher than all the healpred stuff
	HealthValue:GetParent():SetFrameLevel(Health:GetFrameLevel() + 5)

	local Power = self:CreateBackdropStatusBar()
	Power:SetPoint('BOTTOMLEFT')
	Power:SetPoint('BOTTOMRIGHT')
	Power:SetHeight(5)
	Power.colorPower = true
	self.Power = Power

	local Name = Health:CreateText(14)
	Name:SetPoint('LEFT', addon.SPACING, 0)
	Name:SetPoint('RIGHT', HealthValue, 'LEFT', -addon.SPACING, 0)
	Name:SetJustifyH('LEFT')
	self:Tag(Name, '[inomena:namecolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP')
	RaidIcon:SetSize(24, 24)
	self.RaidTargetIndicator = RaidIcon

	local Buffs = self:CreateFrame()
	Buffs:SetPoint('RIGHT', self, 'LEFT', -addon.SPACING, 0)
	Buffs:SetSize(self:GetWidth() * 1/3, self:GetHeight())
	Buffs.growthX = 'LEFT'
	Buffs.growthY = 'UP'
	Buffs.initialAnchor = 'RIGHT'
	Buffs.size = self:GetHeight() - 2
	Buffs.spacing = addon.SPACING
	Buffs.CreateButton = addon.unitShared.CreateAura
	Buffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	Buffs.FilterAura = filterBuffs
	self.Buffs = Buffs

	local Castbar = self:CreateBackdropStatusBar()
	Castbar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -1)
	Castbar:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -1)
	Castbar:SetHeight(18)
	Castbar.timeToHold = 2.5
	Castbar.PostCastStart = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterruptible = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterrupted = addon.unitShared.PostInterruptedCast
	Castbar.PostCastFail = addon.unitShared.PostInterruptedCast
	self.Castbar = Castbar

	local CastbarInterruptible = Castbar:CreateTexture('OVERLAY', 1)
	CastbarInterruptible:SetAllPoints(Castbar:GetStatusBarTexture())
	Castbar.Interruptible = CastbarInterruptible

	local CastbarShielded = Castbar:CreateTexture('OVERLAY', 2)
	CastbarShielded:SetAllPoints(Castbar:GetStatusBarTexture())
	Castbar.Shielded = CastbarShielded

	local CastbarTime = Castbar:CreateText(13)
	CastbarTime:SetPoint('RIGHT', -addon.SPACING, 0)
	CastbarTime:SetJustifyH('RIGHT')
	Castbar.Time = CastbarTime

	local CastbarText = Castbar:CreateText(13)
	CastbarText:SetPoint('LEFT', addon.SPACING, 0)
	CastbarText:SetPoint('RIGHT', CastbarTime, 'LEFT', -3, 0)
	CastbarText:SetJustifyH('LEFT')
	Castbar.Text = CastbarText

end)

oUF:SetActiveStyle(styleName)

for index = 1, 5 do
	local boss = oUF:Spawn('boss' .. index)
	boss:SetPoint('TOP', Minimap, 'BOTTOMLEFT', 0, -(100 + (62 * (index - 1))))
	addon:PixelPerfect(boss)
end
