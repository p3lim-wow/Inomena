local _, addon = ...
local oUF = addon.oUF

local styleName = addon.unitPrefix .. 'Target'
oUF:RegisterStyle(styleName, function(self, unit)
	Mixin(self, addon.widgetMixin)

	self:SetScript('OnEnter', addon.unitShared.ShowTooltip)
	self:SetScript('OnLeave', addon.unitShared.HideTooltip)
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
	Health.DamageAbsorb = DamageAbsorb

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
	self:Tag(Name, '[inomena:classificationcolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP')
	RaidIcon:SetSize(24, 24)
	self.RaidTargetIndicator = RaidIcon

	local Buffs, Debuffs
	if self.CreateAuras then
		Buffs = self:CreateAuras({
			maxWidth = 100, -- enough for 3
			growthX = 'LEFT',
			growthY = 'UP', -- default
			initialAnchor = 'BOTTOMRIGHT',
		})

		Debuffs = self:CreateAuras({
			maxWidth = 220, -- enough for 5
			growthX = 'RIGHT',
			growthY = 'UP', -- default
			initialAnchor = 'BOTTOMLEFT'
		})
	else -- TODO: remove in 12.1
		Buffs = self:CreateFrame()
		Buffs:SetSize(self:GetWidth() * 1/3, self:GetHeight() * 2)
		Buffs.growthX = 'LEFT'
		Buffs.growthY = 'UP' -- default
		Buffs.initialAnchor = 'BOTTOMRIGHT'
		Buffs.PostUpdateButton = addon.unitShared.PostUpdateAura -- for border colors
		self.Buffs = Buffs

		Debuffs = self:CreateFrame()
		Debuffs:SetSize(self:GetWidth() * 2/3, self:GetHeight() * 3)
		Debuffs.growthX = 'RIGHT'
		Debuffs.growthY = 'UP' -- default
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.filter = 'HARMFUL|PLAYER'
		Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura -- for border colors
		self.Debuffs = Debuffs
	end

	Buffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, addon.SPACING)
	Buffs.size = self:GetHeight()
	Buffs.spacing = addon.SPACING
	Buffs.CreateButton = addon.unitShared.CreateAura

	Debuffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, addon.SPACING)
	Debuffs.size = self:GetHeight() * 1.3
	Debuffs.spacing = addon.SPACING
	Debuffs.CreateButton = addon.unitShared.CreateAura

	if self.CreateAuras then
		Buffs:AddGroup('HELPFUL', {
			showBuffBorder = true, -- custom option
		})

		if addon.PLAYER_CLASS == 'HUNTER' then
			-- as a hunter I'd like to see Hunter's Mark from any hunter
			-- TODO: I'd love if I could filter that to _friendly_ casters
			Debuffs:AddGroup('HARMFUL|PLAYER', {
				candidateFilters = {
					excludeSpellIDs = {
						[257284] = true, -- Hunter's Mark
					}
				}
			})
			Debuffs:AddGroup('HARMFUL', {
				candidateFilters = {
					includeSpellIDs = {
						[257284] = true, -- Hunter's Mark
					}
				}
			})
		else
			Debuffs:AddGroup('HARMFUL|PLAYER') -- TBD: filter some stuff?
		end
	end

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
