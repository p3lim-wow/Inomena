local _, addon = ...
local oUF = addon.oUF

local function updateOnAdded(self)
	local unit = self.unit

	if UnitNameplateShowsWidgetsOnly(unit) or UnitIsGameObject(unit) then
		self.Name:Hide()
		self.FriendlyName:Hide()
		self.PetIcon:Hide()
		self:DisableElement('Health')
		self:DisableElement('Auras')
		self:DisableElement('Castbar')
		return
	elseif UnitIsFriend('player', unit) then
		self.Name:Hide()
		self.FriendlyName:Show()
		self.PetIcon:Hide()
		self:DisableElement('Health')
		self:DisableElement('Auras')
		self:DisableElement('Castbar')
		return
	else
		self.Name:Hide() -- we change this later
		self.FriendlyName:Hide()
		self:EnableElement('Health')
		self:EnableElement('Auras')
		self:EnableElement('Castbar')
	end

	local fullSize = false
	if IsInInstance() or UnitThreatSituation('player', unit) then
		-- not in instance or not in combat with the plate
		fullSize = true
	end

	local classification = UnitClassification(unit)
	if classification == 'minus' then
		-- trivial mobs should be small unless targeted
		fullSize = false
	end

	if UnitIsUnit(unit, 'target') then
		fullSize = true
		self.Health:SetBorderColor(1, 1, 1)
		self.Castbar:SetBorderColor(1, 1, 1)
		self.Castbar.IconFrame:SetBorderColor(1, 1, 1)
	elseif not UnitIsUnit(unit, 'mouseover') then
		-- reset border
		self.Health:SetBorderColor(0, 0, 0)
		self.Castbar:SetBorderColor(0, 0, 0)
		self.Castbar.IconFrame:SetBorderColor(0, 0, 0)
	end

	if C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
		-- quest mobs always have name shown
		self.Name:Show()
	end

	if fullSize then
		self.Name:Show()
		self.Health:SetHeight(20)
		self.HealthValue:Show()
	else
		self.Health:SetHeight(4)
		self.HealthValue:Hide()
	end

	self.PetIcon:SetShown(UnitIsOtherPlayersPet(unit))
end

local function updateOnRemoved(self)
	 -- reset highlight and such
	self.Highlight:Hide()
	self.Health:SetBorderColor(0, 0, 0)
end

local function updateHighlight(self, event, worldCursorAnchorType)
	-- we check specific events to avoid UAE
	local r, g, b = 0, 0, 0
	if event == 'WORLD_CURSOR_TOOLTIP_UPDATE' and worldCursorAnchorType == Enum.WorldCursorAnchorType.None then
		-- mouse left the nameplate
		self.Highlight:Hide()
		if UnitIsUnit(self.unit, 'target') then
			r, g, b = 1, 1, 1
		end
	elseif event == 'UPDATE_MOUSEOVER_UNIT' then
		-- mouse entered some unit
		if UnitIsUnit(self.unit, 'mouseover') then
			self.Highlight:Show()
			r, g, b = 1, 1, 0 -- yellow
		else
			-- repeat of the logic for world cursor none
			self.Highlight:Hide()
			if UnitIsUnit(self.unit, 'target') then
				r, g, b = 1, 1, 1
			end
		end
	end

	self.Health:SetBorderColor(r, g, b)
	self.Castbar:SetBorderColor(r, g, b)
	self.Castbar.IconFrame:SetBorderColor(r, g, b)
end

local function filterBuffs(_, unit)
	-- we only use this to show buffs on mobs, for purge or de-enrage
	return not UnitIsPlayer(unit)
end

local styleName = addon.unitPrefix .. 'NamePlates'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)
	addon:PixelPerfect(self)

	local Health = self:CreateBackdropStatusBar()
	Health:SetPoint('LEFT')
	Health:SetPoint('RIGHT')
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
	HealthValue:SetPoint('RIGHT', Health, 'TOPRIGHT', -2, -1)
	HealthValue:SetJustifyH('RIGHT')
	HealthValue:SetFrameLevel(8)
	HealthValue:Hide()
	self.HealthValue = HealthValue
	self:Tag(HealthValue, '[inomena:hpper]')

	local Highlight = Health:CreateTexture('OVERLAY', 1)
	Highlight:SetAllPoints(Health:GetStatusBarTexture())
	Highlight:SetColorTexture(1, 1, 1, 0.5)
	Highlight:Hide()
	self.Highlight = Highlight
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', updateHighlight, true)
	self:RegisterEvent('WORLD_CURSOR_TOOLTIP_UPDATE', updateHighlight, true)

	local Name = self:CreateText(14)
	Name:SetPoint('LEFT', Health, 'TOPLEFT', 2, -1)
	Name:SetPoint('RIGHT', HealthValue, 'LEFT', 1, 0)
	Name:SetJustifyH('LEFT')
	Name:SetWordWrap(false)
	Name:SetFrameLevel(10)
	self.Name = Name
	self:Tag(Name, '[inomena:quest][inomena:namecolor][inomena:name<$|r]')

	local FriendlyName = self:CreateText(14)
	FriendlyName:SetPoint('CENTER')
	FriendlyName:SetJustifyH('CENTER')
	FriendlyName:SetFrameLevel(10)
	self.FriendlyName = FriendlyName
	self:Tag(FriendlyName, '[inomena:reactioncolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP', 0, addon.SPACING)
	RaidIcon:SetSize(22, 22)
	self.RaidTargetIndicator = RaidIcon

	local PetIcon = Health:CreateTexture('OVERLAY')
	PetIcon:SetPoint('CENTER', Health, 'BOTTOMLEFT')
	PetIcon:SetAtlas('wildbattlepetcapturable')
	PetIcon:SetSize(12, 12)
	self.PetIcon = PetIcon

	local Debuffs = self:CreateFrame()
	Debuffs:SetPoint('BOTTOMLEFT', Health, 'TOPLEFT', 0, addon.SPACING)
	Debuffs:SetSize(120, 140)
	Debuffs.initialAnchor = 'BOTTOMLEFT'
	Debuffs.growthX = 'RIGHT'
	Debuffs.growthY = 'UP'
	Debuffs.spacing = addon.SPACING
	Debuffs.height = 20
	Debuffs.width = 30
	Debuffs.filter = 'HARMFUL|PLAYER'
	Debuffs.disableMouse = true -- custom option
	Debuffs.CreateButton = addon.unitShared.CreateAura
	self.Debuffs = Debuffs

	local Buffs = self:CreateFrame()
	Buffs:SetPoint('BOTTOMRIGHT', Health, 'TOPRIGHT', 0, addon.SPACING)
	Buffs:SetSize(80, 140)
	Buffs.initialAnchor = 'BOTTOMRIGHT'
	Buffs.growthX = 'LEFT'
	Buffs.growthY = 'UP'
	Buffs.spacing = addon.SPACING
	Buffs.size = 34
	Buffs.num = 3
	Buffs.disableMouse = true -- custom option
	Buffs.CreateButton = addon.unitShared.CreateAura
	Buffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	Buffs.FilterAura = filterBuffs
	self.Buffs = Buffs

	local Castbar = self:CreateBackdropStatusBar()
	Castbar:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, -1)
	Castbar:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -1)
	Castbar:SetHeight(14)
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

	local CastbarText = Castbar:CreateText(12)
	CastbarText:SetPoint('LEFT', 2, 0)
	CastbarText:SetJustifyH('LEFT')
	CastbarText:SetFrameLevel(10)
	Castbar.Text = CastbarText

	local CastbarIconFrame = Castbar:CreateBackdropFrame()
	CastbarIconFrame:SetPoint('BOTTOMRIGHT', Castbar, 'BOTTOMLEFT', -1, 0)
	CastbarIconFrame:SetPoint('TOPRIGHT', Health, 'TOPLEFT', -1, 0)
	CastbarIconFrame:SetSize(34, 34)
	Castbar.IconFrame = CastbarIconFrame

	local CastbarIcon = CastbarIconFrame:CreateIcon()
	CastbarIcon:SetAllPoints()
	Castbar.Icon = CastbarIcon

	local Threat = Health:CreateFrame('Frame', 'BackdropTemplate')
	Threat:SetPoint('TOPLEFT', -5, 5)
	Threat:SetPoint('BOTTOMRIGHT', 5, -5)
	Threat:SetFrameStrata('BACKGROUND')
	Threat:SetBackdrop(addon.GLOW)
	Threat.PostUpdate = addon.unitShared.PostUpdateThreat
	Threat.feedbackUnit = 'player'
	self.ThreatIndicator = Threat

	self:RegisterEvent('PLAYER_REGEN_DISABLED', updateOnAdded, true) -- for combat state changes
	self:RegisterEvent('PLAYER_REGEN_ENABLED', updateOnAdded, true) -- for combat state changes
	self:RegisterEvent('PLAYER_TARGET_CHANGED', updateOnAdded, true)
	self:RegisterEvent('UNIT_FLAGS', updateOnAdded) -- for reaction state changes
	self:RegisterEvent('UNIT_HEALTH', updateOnAdded) -- extra updates
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', updateOnAdded, true) -- for threat border updates
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', updateOnAdded, true)
end)

oUF:SetActiveStyle(styleName)

local nameplates = oUF:SpawnNamePlates()
nameplates:SetAddedCallback(updateOnAdded)
nameplates:SetRemovedCallback(updateOnRemoved)
nameplates:SetSize(200, 22) -- we keep it wide just because of stupid long names, no other reason

nameplates:SetCVars({
	-- from the settings, in order
	nameplateShowAll = 1,
	nameplateShowEnemies = 1,
	nameplateShowEnemyPets = 1,
	nameplateShowEnemyMinus = 1,
	nameplateShowFriendlyPlayers = 0,
	nameplateShowFriendlyPlayerMinions = 0,
	nameplateShowFriendlyNpcs = 0,
	nameplateShowOffscreen = 0,
	nameplateStackingTypes = {
		[Enum.NamePlateStackType.Enemy] = true,
		[Enum.NamePlateStackType.Friendly] = false,
	},
	nameplateSize = 2,
	nameplateAuraScale = 0.70, -- can't go lower, higher increases nameplate vertical offset
	nameplateStyle = 0,
	nameplateInfoDisplay = {
		[Enum.NamePlateInfoDisplay.CurrentHealthPercent] = false,
		[Enum.NamePlateInfoDisplay.CurrentHealthValue] = false,
		[Enum.NamePlateInfoDisplay.RarityIcon] = false,
	},
	nameplateCastBarDisplay = {
		[Enum.NamePlateCastBarDisplay.SpellName] = false,
		[Enum.NamePlateCastBarDisplay.SpellIcon] = false,
		[Enum.NamePlateCastBarDisplay.SpellTarget] = false,
		[Enum.NamePlateCastBarDisplay.HighlightImportantCasts] = false,
		[Enum.NamePlateCastBarDisplay.HighlightWhenCastTarget] = false,
	},
	nameplateThreatDisplay = {
		[Enum.NamePlateThreatDisplay.Progressive] = false,
		[Enum.NamePlateThreatDisplay.Flash] = false,
		[Enum.NamePlateThreatDisplay.HealthBarColor] = false,
	},
	nameplateEnemyNpcAuraDisplay = {
		[Enum.NamePlateEnemyNpcAuraDisplay.Buffs] = false,
		[Enum.NamePlateEnemyNpcAuraDisplay.Debuffs] = false,
		[Enum.NamePlateEnemyNpcAuraDisplay.CrowdControl] = false,
	},
	nameplateEnemyPlayerAuraDisplay = {
		[Enum.NamePlateEnemyPlayerAuraDisplay.Buffs] = false,
		[Enum.NamePlateEnemyPlayerAuraDisplay.Debuffs] = false,
		[Enum.NamePlateEnemyPlayerAuraDisplay.LossOfControl] = false,
	},
	nameplateFriendlyPlayerAuraDisplay = {
		[Enum.NamePlateFriendlyPlayerAuraDisplay.Buffs] = false,
		[Enum.NamePlateFriendlyPlayerAuraDisplay.Debuffs] = false,
		[Enum.NamePlateFriendlyPlayerAuraDisplay.LossOfControl] = false,
	},
	nameplateDebuffPadding = 0,
	nameplateSimplifiedTypes = {
		[Enum.NamePlateSimplifiedType.Minion] = false,
		[Enum.NamePlateSimplifiedType.MinusMob] = false,
		[Enum.NamePlateSimplifiedType.FriendlyPlayer] = false,
		[Enum.NamePlateSimplifiedType.FriendlyNpc] = false,
	},

	-- hidden cvars
	nameplateShowOnlyNameForFriendlyPlayerUnits = 1,
	nameplateUseClassColorForFriendlyPlayerUnitNames = 1,
})
