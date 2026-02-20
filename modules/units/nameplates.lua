local _, addon = ...
local oUF = addon.oUF

local function updateAnchors(self)
	if self.Castbar:IsShown() then
		self.TargetOutline:SetPoint('BOTTOM', self.Castbar, 0, -4)
	else
		self.TargetOutline:SetPoint('BOTTOM', self.Health, 0, -4)
	end
end

local function updateOnAdded(self)
	local unit = self.unit

	if UnitNameplateShowsWidgetsOnly(unit) or UnitIsGameObject(unit) then
		self.Name:Hide()
		self.FriendlyName:Hide()
		self.PetIcon:Hide()
		self.Health:Hide()
		self:DisableElement('Health')
		self:DisableElement('Auras')
		self:DisableElement('Castbar')
		return
	elseif UnitIsFriend('player', unit) and not UnitIsPossessed(unit) and not UnitIsCharmed(unit) then
		self.Name:Hide()
		self.FriendlyName:Show()
		self.PetIcon:Hide()
		self.Health:Hide()
		self:DisableElement('Health')
		self:DisableElement('Auras')
		self:DisableElement('Castbar')
		return
	else
		self.Name:Hide() -- we change this later
		self.FriendlyName:Hide()
		self.Health:Show()
		self:EnableElement('Health')
		self:EnableElement('Auras')
		self:EnableElement('Castbar')
	end

	local fullSize = false
	if IsInInstance() or UnitThreatSituation('player', unit) then
		-- in instance or in combat with the player
		fullSize = true
	end

	local classification = UnitClassification(unit)
	if classification == 'minus' then
		-- trivial mobs should be small unless targeted
		fullSize = false
	end

	if UnitIsUnit(unit, 'target') then
		fullSize = true

		self.TargetOutline:Show()
	else
		self.TargetOutline:Hide()
	end

	if C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
		-- quest mobs always have name shown
		self.Name:Show()
	elseif classification == 'rare' or classification == 'rareelite' then
		-- always show rare name
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

	updateAnchors(self)

	self.PetIcon:SetShown(UnitIsOtherPlayersPet(unit))
	C_Timer.After(0, GenerateClosure(self.Health.ForceUpdate, self.Health)) -- temp fix
end

local function updateOnRemoved(self)
	 -- reset highlight
	self.Highlight:Hide()
end

local function updateHighlight(self, event, worldCursorAnchorType)
	if event == 'WORLD_CURSOR_TOOLTIP_UPDATE' and worldCursorAnchorType == Enum.WorldCursorAnchorType.None then
		-- mouse left the nameplate
		self.Highlight:Hide()
	elseif event == 'UPDATE_MOUSEOVER_UNIT' then
		-- mouse entered some unit
		if UnitIsUnit(self.unit, 'mouseover') then
			self.Highlight:Show()
		else
			self.Highlight:Hide()
		end
	end
end

local function postCCCreate(_, Button)
	Button.Cooldown:ClearTimePoints()
	Button.Cooldown:SetTimePoint('CENTER')
end

local function filterBuffs(_, unit)
	-- we only use this to show buffs on mobs, for purge or de-enrage
	return not UnitIsPlayer(unit)
end

local filterDebuffs; do
	local function matches(filter, unit, data) -- shorthand
		return not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, filter)
	end

	function filterDebuffs(_, ...)
		-- we only show player-applied debuffs, but not CC as it's handled by a different element
		return matches('HARMFUL|PLAYER', ...) and not matches('HARMFUL|CROWD_CONTROL', ...)
	end
end

local styleName = addon.unitPrefix .. 'NamePlates'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	addon:PixelPerfect(self)

	local Health = self:CreateBackdropStatusBar()
	Health:SetPoint('LEFT')
	Health:SetPoint('RIGHT')
	Health:SetBackgroundColor(0, 0, 0, 0.7)
	Health.colorReaction = true -- we only set these so oUF registers events
	Health.colorSelection = true
	Health.UpdateColor = addon.unitShared.UpdateColorHealth
	self.Health = Health

	local DamageAbsorb = Health:CreateStatusBar()
	DamageAbsorb:SetPoint('TOP')
	DamageAbsorb:SetPoint('BOTTOM')
	DamageAbsorb:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	DamageAbsorb:SetStatusBarColor(addon.colors.absorb:GetRGB())
	Health.DamageAbsorb = DamageAbsorb

	local HealthValue = Health:CreateText()
	HealthValue:SetPoint('RIGHT', Health, 'TOPRIGHT', -2, -1)
	HealthValue:SetJustifyH('RIGHT')
	HealthValue:SetFrameLevel(8)
	HealthValue:Hide()
	self.HealthValue = HealthValue
	self:Tag(HealthValue, '[inomena:hpper]')

	local Highlight = Health:CreateTexture('OVERLAY', 1)
	Highlight:SetAllPoints(Health:GetStatusBarTexture())
	Highlight:SetColorTexture(addon.colors.highlight:GetRGBA())
	Highlight:Hide()
	self.Highlight = Highlight
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', updateHighlight, true)
	self:RegisterEvent('WORLD_CURSOR_TOOLTIP_UPDATE', updateHighlight, true)

	local Name = Health:CreateText(14)
	Name:SetPoint('LEFT', Health, 'TOPLEFT', 2, -1)
	Name:SetPoint('RIGHT', HealthValue, 'LEFT', 1, 0)
	Name:SetJustifyH('LEFT')
	Name:SetWordWrap(false)
	Name:SetFrameLevel(10)
	self.Name = Name
	self:Tag(Name, '[inomena:quest][inomena:classificationcolor][inomena:name<$|r]')

	local FriendlyName = self:CreateText(14)
	FriendlyName:SetPoint('CENTER')
	FriendlyName:SetJustifyH('CENTER')
	FriendlyName:SetFrameLevel(10)
	self.FriendlyName = FriendlyName
	self:Tag(FriendlyName, '[inomena:reactioncolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP', 0, addon.SPACING)
	RaidIcon:SetSize(30, 30)
	self.RaidTargetIndicator = RaidIcon

	local PetIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	PetIcon:SetPoint('CENTER', Health, 'BOTTOMLEFT')
	PetIcon:SetAtlas('wildbattlepetcapturable')
	PetIcon:SetSize(12, 12)
	self.PetIcon = PetIcon

	local Debuffs = Health:CreateFrame()
	Debuffs:SetPoint('BOTTOMLEFT', Health, 'TOPLEFT', 0, addon.SPACING)
	Debuffs:SetSize(120, 140)
	Debuffs.initialAnchor = 'BOTTOMLEFT'
	Debuffs.growthX = 'RIGHT'
	Debuffs.growthY = 'UP'
	Debuffs.spacing = addon.SPACING
	Debuffs.height = 20
	Debuffs.width = 30
	Debuffs.filter = 'HARMFUL|PLAYER' -- we filter it further in FilterAura override
	Debuffs.disableCooldownText = true -- custom option
	Debuffs.disableMouse = true -- custom option
	Debuffs.CreateButton = addon.unitShared.CreateAura
	Debuffs.FilterAura = filterDebuffs
	self.Debuffs = Debuffs

	local Buffs = Health:CreateFrame()
	Buffs:SetPoint('BOTTOMRIGHT', Health, 'TOPRIGHT', 0, addon.SPACING)
	Buffs:SetSize(80, 140)
	Buffs.initialAnchor = 'BOTTOMRIGHT'
	Buffs.growthX = 'LEFT'
	Buffs.growthY = 'UP'
	Buffs.spacing = addon.SPACING
	Buffs.size = 34
	Buffs.num = 3
	Buffs.disableCooldownText = true -- custom option
	Buffs.disableMouse = true -- custom option
	Buffs.CreateButton = addon.unitShared.CreateAura
	Buffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	Buffs.FilterAura = filterBuffs
	self.Buffs = Buffs

	local CrowdControlDebuffs = self:CreateFrame()
	CrowdControlDebuffs:SetPoint('LEFT', Health, 'RIGHT', addon.SPACING, 0)
	CrowdControlDebuffs:SetSize(80, 140)
	CrowdControlDebuffs.initialAnchor = 'LEFT'
	CrowdControlDebuffs.growthX = 'RIGHT'
	CrowdControlDebuffs.growthY = 'UP'
	CrowdControlDebuffs.spacing = addon.SPACING
	CrowdControlDebuffs.size = 36
	CrowdControlDebuffs.numDebuffs = 3
	CrowdControlDebuffs.numBuffs = 0
	CrowdControlDebuffs.debuffFilter = 'HARMFUL|CROWD_CONTROL'
	CrowdControlDebuffs.disableMouse = true -- custom option
	CrowdControlDebuffs.CreateButton = addon.unitShared.CreateAura
	CrowdControlDebuffs.PostCreateButton = postCCCreate
	self.Auras = CrowdControlDebuffs

	local Castbar = Health:CreateBackdropStatusBar()
	Castbar:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, -1)
	Castbar:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -1)
	Castbar:SetHeight(20)
	Castbar:HookScript('OnShow', GenerateFlatClosure(updateAnchors, self))
	Castbar:HookScript('OnHide', GenerateFlatClosure(updateAnchors, self))
	Castbar.timeToHold = 2.5
	Castbar.PostCastStart = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterruptible = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterrupted = addon.unitShared.PostInterruptedCast
	Castbar.PostCastFail = addon.unitShared.PostInterruptedCast
	self.Castbar = Castbar

	local CastbarInterruptible = Castbar:CreateTexture('OVERLAY', 1) -- level is important
	CastbarInterruptible:SetAllPoints(Castbar:GetStatusBarTexture())
	Castbar.Interruptible = CastbarInterruptible

	local CastbarShielded = Castbar:CreateTexture('OVERLAY', 2) -- level is important
	CastbarShielded:SetAllPoints(Castbar:GetStatusBarTexture())
	Castbar.Shielded = CastbarShielded

	local CastbarText = Castbar:CreateText(14)
	CastbarText:SetPoint('LEFT', 2, 0)
	CastbarText:SetJustifyH('LEFT')
	CastbarText:SetFrameLevel(10)
	Castbar.Text = CastbarText

	local Threat = Health:CreateFrame('Frame', 'BackdropTemplate')
	Threat:SetPoint('TOPLEFT', -5, 5)
	Threat:SetPoint('BOTTOMRIGHT', 5, -5)
	Threat:SetFrameStrata('BACKGROUND')
	Threat:SetBackdrop(addon.GLOW)
	Threat.PostUpdate = addon.unitShared.PostUpdateThreat
	Threat.feedbackUnit = 'player'
	self.ThreatIndicator = Threat

	local TargetOutline = Health:CreateBackdropStatusBar()
	TargetOutline:SetPoint('TOPLEFT', -4, 4)
	TargetOutline:SetPoint('TOPRIGHT', 4, 4)
	TargetOutline:SetPoint('BOTTOM', 0, -4)
	TargetOutline:SetFrameStrata('BACKGROUND')
	TargetOutline:SetMinMaxValues(0, 1)
	TargetOutline:SetValue(1)
	TargetOutline:Hide()
	self.TargetOutline = TargetOutline

	self:RegisterEvent('PLAYER_REGEN_DISABLED', updateOnAdded, true) -- for combat state changes
	self:RegisterEvent('PLAYER_REGEN_ENABLED', updateOnAdded, true) -- for combat state changes
	self:RegisterEvent('PLAYER_TARGET_CHANGED', updateOnAdded, true)
	self:RegisterEvent('UNIT_FLAGS', updateOnAdded) -- for reaction state changes (?)
	self:RegisterEvent('UNIT_HEALTH', updateOnAdded) -- extra updates
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', updateOnAdded, true) -- for threat border updates
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', updateOnAdded, true)
end)

oUF:SetActiveStyle(styleName)

local nameplates = oUF:SpawnNamePlates()
nameplates:SetAddedCallback(updateOnAdded)
nameplates:SetRemovedCallback(updateOnRemoved)
nameplates:SetSize(200, 40) -- we keep it wide just because of stupid long names, no other reason

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

-- use our font for friendly nameplates in instances
for _, fontObject in next, {
	'SystemFont_NamePlate',
	'SystemFont_NamePlateFixed',
	'SystemFont_NamePlate_Outlined',
	'SystemFont_LargeNamePlate',
	'SystemFont_LargeNamePlateFixed',
} do
	-- font size doesn't seem to matter, they'll be resized anyways?
	_G[fontObject]:SetFont(addon.FONT, 16, 'OUTLINE')
end
