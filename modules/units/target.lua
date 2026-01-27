local _, addon = ...
local oUF = addon.oUF

local styleName = addon.unitPrefix .. 'Target'
oUF:RegisterStyle(styleName, function(self, unit)
	Mixin(self, addon.widgetMixin)

	self:SetScript('OnEnter', addon.unitShared.Tooltip)
	self:SetScript('OnLeave', GameTooltip_Hide)
	self:RegisterForClicks('AnyUp')
	self:SetSize(320, 30)

	addon.unitShared.AddShiftClick(self, unit)
	addon.unitShared.AddMiddleClick(self)

	local Health = self:CreateBackdropStatusBar()
	Health:SetAllPoints()
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
	self.HealthPrediction.damageAbsorb = DamageAbsorb

	local HealthValue = Health:CreateText()
	HealthValue:SetPoint('RIGHT', -addon.SPACING, 0)
	HealthValue:SetJustifyH('RIGHT')
	self:Tag(HealthValue, '[inomena:hpcur][ $>inomena:hptarget]')

	-- need to render texts higher than all the healpred stuff
	HealthValue:GetParent():SetFrameLevel(Health:GetFrameLevel() + 5)

	local Power = self:CreateBackdropStatusBar()
	Power:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -addon.SPACING)
	Power:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -addon.SPACING)
	Power:SetHeight(5)
	Power.colorPower = true
	self.Power = Power

	local Name = Health:CreateText()
	Name:SetPoint('LEFT', addon.SPACING, 0)
	Name:SetPoint('RIGHT', HealthValue, 'LEFT', -addon.SPACING, 0)
	Name:SetJustifyH('LEFT')
	self:Tag(Name, '[inomena:namecolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP')
	RaidIcon:SetSize(24, 24)
	self.RaidTargetIndicator = RaidIcon

	local Buffs = self:CreateFrame()
	Buffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, addon.SPACING)
	Buffs:SetSize(self:GetWidth() * 1/3, self:GetHeight() * 2)
	Buffs.growthX = 'LEFT'
	Buffs.growthY = 'UP'
	Buffs.initialAnchor = 'BOTTOMRIGHT'
	Buffs.size = self:GetHeight()
	Buffs.spacing = addon.SPACING
	Buffs.CreateButton = addon.unitShared.CreateAura
	Buffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	self.Buffs = Buffs

	local Debuffs = self:CreateFrame()
	Debuffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, addon.SPACING)
	Debuffs:SetSize(self:GetWidth() * 2/3, self:GetHeight() * 3)
	Debuffs.growthX = 'RIGHT'
	Debuffs.growthY = 'UP'
	Debuffs.initialAnchor = 'BOTTOMLEFT'
	Debuffs.filter = 'HARMFUL|PLAYER'
	Debuffs.size = self:GetHeight() * 1.3
	Debuffs.spacing = addon.SPACING
	Debuffs.CreateButton = addon.unitShared.CreateAura
	Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	self.Debuffs = Debuffs

	local Castbar = self:CreateBackdropStatusBar()
	Castbar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -15)
	Castbar:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -15)
	Castbar:SetHeight(18)
	Castbar.timeToHold = 2.5
	Castbar.PostCastStart = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterruptible = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterrupted = addon.unitShared.PostInterruptedCast
	Castbar.PostCastFail = addon.unitShared.PostInterruptedCast
	self.Castbar = Castbar

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

	local CastbarIconFrame = Castbar:CreateBackdropFrame()
	CastbarIconFrame:SetPoint('BOTTOMRIGHT', Castbar, 'BOTTOMLEFT', -addon.SPACING, 0)
	CastbarIconFrame:SetSize(34, 34)

	local CastbarIcon = CastbarIconFrame:CreateIcon()
	CastbarIcon:SetAllPoints()
	Castbar.Icon = CastbarIcon
end)

oUF:SetActiveStyle(styleName)

local target = oUF:Spawn('target')
target:SetPoint('CENTER', 420, -260)
addon:PixelPerfect(target)

-- expose internally
addon.units.target = target
