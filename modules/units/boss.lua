local _, addon = ...
local oUF = addon.oUF

local function updateOutline(self)
	self.FocusOutline:SetShown(UnitIsUnit(self.__unit, 'focus'))
end

local function updateOutlineAnchors(self)
	if self.Castbar:IsShown() then
		self.FocusOutline:SetPoint('BOTTOM', self.Castbar, 0, -4)
		self.FocusOutline.edges.Bottom:SetPoint('TOP', self.Castbar, 'BOTTOM')
	else
		self.FocusOutline:SetPoint('BOTTOM', self.Health, 0, -4)
		self.FocusOutline.edges.Bottom:SetPoint('TOP', self.Health, 'BOTTOM')
	end
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
	HealAbsorb:GetStatusBarTexture():SetAtlas('RaidFrame-Absorb-Overlay', false, nil, nil, 'REPEAT', 'REPEAT')
	HealAbsorb:GetStatusBarTexture():SetHorizTile(true)
	HealAbsorb:GetStatusBarTexture():SetVertTile(true)
	HealAbsorb:GetStatusBarTexture():SetVertexColor(0, 0, 0)
	HealAbsorb:SetReverseFill(true)
	Health.HealAbsorb = HealAbsorb

	local OverHealAbsorbIndicator = Health:CreateTexture()
	OverHealAbsorbIndicator:SetPoint('TOP', Health, 0, 2)
	OverHealAbsorbIndicator:SetPoint('BOTTOM', Health, 0, -2)
	OverHealAbsorbIndicator:SetPoint('RIGHT', Health, 'LEFT', 3, 0)
	OverHealAbsorbIndicator:SetWidth(10)
	Health.OverHealAbsorbIndicator = OverHealAbsorbIndicator

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
	self:Tag(Name, '[inomena:classificationcolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP')
	RaidIcon:SetSize(24, 24)
	self.RaidTargetIndicator = RaidIcon

	local Buffs = self:CreateAuras({
		growthX = 'LEFT',
		growthY = 'UP', -- default
		initialAnchor = 'RIGHT'
	})
	Buffs:SetPoint('RIGHT', self, 'LEFT', -addon.SPACING, 0)
	Buffs.elementSpacing = addon.SPACING
	Buffs.lineSpacing = addon.SPACING
	Buffs.showCount = true
	Buffs.size = self:GetHeight() - 2
	Buffs.tooltipAnchor = 'ANCHOR_BOTTOMLEFT'
	Buffs.tooltipOffsetX = -3
	Buffs.tooltipOffsetY = self:GetHeight() - 4 -- this is some jank
	Buffs.PostCreateButton = addon.unitShared.PostCreateAura
	Buffs:AddGroup('HELPFUL|PLAYER')
	Buffs:AddGroup('HELPFUL|!PLAYER|IMPORTANT')
	Buffs:AddGroup('HELPFUL|!PLAYER|DISPELLABLE')
	Buffs:AddGroup('HELPFUL|!PLAYER', {
		candidateFilters = {
			isBossOrRoleAura = true,
		}
	})

	addon.unitShared.CreateDispelOverlay(self)

	local Castbar = self:CreateBackdropStatusBar()
	Castbar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -1)
	Castbar:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -1)
	Castbar:SetHeight(18)
	Castbar:HookScript('OnShow', GenerateFlatClosure(updateOutlineAnchors, self))
	Castbar:HookScript('OnHide', GenerateFlatClosure(updateOutlineAnchors, self))
	Castbar.timeToHold = 2.5
	Castbar.PostCastStart = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterruptible = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterrupted = addon.unitShared.PostInterruptedCast
	Castbar.PostCastFail = addon.unitShared.PostFailedCast
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

	local FocusOutline = addon:CreateOutline(Health)
	FocusOutline:SetColor(1, 0, 0)
	FocusOutline:Hide()
	self.FocusOutline = FocusOutline

	self:RegisterEvent('PLAYER_FOCUS_CHANGED', updateOutline, true)
	self:RegisterEvent('PLAYER_LOGIN', updateOutline, true)
end)

oUF:SetActiveStyle(styleName)

for index = 1, 5 do
	local boss = oUF:Spawn('boss' .. index)
	boss:SetPoint('TOP', Minimap, 'BOTTOMLEFT', 0, -(100 + (62 * (index - 1))))
	addon:PixelPerfect(boss)
end
