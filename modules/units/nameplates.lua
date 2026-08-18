local _, addon = ...
local oUF = addon.oUF

local function updateOutlineAnchors(self)
	local relative = self.Castbar:IsShown() and self.Castbar or self.Health
	self.TargetOutline:SetPoint('BOTTOM', relative, 0, -4)
	self.TargetOutline.edges.Bottom:SetPoint('TOP', relative, 'BOTTOM')
end

local function updateOnAdded(self)
	local unit = self.__unit
	if not UnitCanAttack('player', unit) then
		self.FriendlyName:Show()
		self.Name:Hide()

		-- pause elements to hide them
		self:PauseElement('Health')
		self:PauseElement('Auras')
		self:PauseElement('Castbar')
		return
	else
		self.FriendlyName:Hide()
		self.Name:Hide() -- we change this later
	end

	local isTarget = UnitIsUnit(unit, 'target')
	if (UnitIsPlayer(unit) or UnitIsOtherPlayersPet(unit)) and UnitReaction(unit, 'player') < 4 and not (GetPVPDesired() or IsPVPTimerRunning() or C_PvP.IsWarModeDesired()) and not isTarget then
		-- "hide" nameplates for players (and pets) that have PvP enabled when the player doesn't
		-- (this is something Blizzard should handle tbh)
		self:PauseAllElements()
		return
	end

	self:ResumeAllElements()

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

	if isTarget then
		fullSize = true

		self.Buffs:SetPointsOffset(3, addon.SPACING + 3)
		self.Debuffs:SetPointsOffset(-3, addon.SPACING + 3)
		self.CrowdControl:SetPointsOffset(addon.SPACING + 3, 0)
		self.TargetOutline:Show()
		updateOutlineAnchors(self)
	else
		self.Buffs:SetPointsOffset(0, addon.SPACING)
		self.Debuffs:SetPointsOffset(0, addon.SPACING)
		self.CrowdControl:SetPointsOffset(addon.SPACING, 0)
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
		self.Health:SetHeight(28)
		self.HealthValue:Show()
	else
		self.Health:SetHeight(4)
		self.HealthValue:Hide()
	end

	self.PetIcon:SetShown(UnitIsOtherPlayersPet(unit))
	self.EliteIcon:SetShown(classification == 'elite' and not fullSize)

	self.Health:SetFrameLevel(4)
	self.Name:SetFrameLevel(5)
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
		if C_Secrets.CanCompareUnitTokens(self.__unit, 'mouseover') and UnitIsUnit(self.__unit, 'mouseover') then
			self.Highlight:Show()
		else
			self.Highlight:Hide()
		end
	end
end

local function updateHealthColor(self, event, unit)
	if event == 'PLAYER_FOCUS_CHANGED' then
		-- it's unitless
		unit = self.__unit
	end

	if not unit or self.__unit ~= unit then
		return
	end

	local color
	if addon:IsInDungeon() then
		local groupRole = UnitGroupRolesAssignedEnum('player')
		if groupRole >= 0 then -- no role = -1, missing enum value
			local threatStatus = UnitThreatSituation('player', unit)
			color = addon.unitShared.GetThreatColor(groupRole, threatStatus)
		end

		if not color then
			color = addon.colors.nameplate
		end
	end

	if color then
		self.Health:SetStatusBarColor(color:GetRGB())
	else
		addon.unitShared.UpdateColorHealth(self, event, unit)
	end
end

local function updateBuffFilters(element)
	local dispelTypes = addon:GetDispelTypes('HELPFUL')
	element:SetAuraGroupCandidateFilters(element.dispelGroup, {
		includeDispelTypes = dispelTypes
	})
	element:SetAuraGroupCandidateFilters(element.buffsGroup, {
		excludeDispelTypes = dispelTypes
	})
end

local styleName = addon.unitPrefix .. 'NamePlates'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	addon:PixelPerfect(self)

	-- after scaling the oUF unit frame (which at 1440p would be 0.533), we also have to take
	-- into account that nameplates (the unit frame parent) _will_ get scaled by UIParent, although
	-- on creation the nameplate will not have this scale so we have to get it directly
	local SCALED_WIDTH = self:GetWidth() * UIParent:GetScale()

	-- nameplates take up the space by the visibile anchored children by default, which changes
	-- whenever we alter the health size, the castbar shows up, or buffs/debuffs gets added or
	-- removed, resulting in a "bouncy" nameplate.
	-- to prevent this we add a static frame to use as our bounds
	local bounds = CreateFrame('Frame', nil, self)
	bounds:SetAllPoints()
	self:GetParent():SetStackingBoundsFrame(bounds)

	-- however, this still only works when there's something occupying the bounds frame, so we'll
	-- add a texture to it but make it fully transparent
	local filler = bounds:CreateTexture()
	filler:SetAllPoints()
	filler:SetColorTexture(0, 0, 0, 0)

	local Health = self:CreateBackdropStatusBar()
	Health:SetPoint('LEFT')
	Health:SetPoint('RIGHT')
	Health:SetBackgroundColor(0, 0, 0, 0.7)
	Health.colorReaction = true -- we only set these so oUF registers events
	Health.colorSelection = true
	Health.colorThreat = true
	Health.UpdateColor = updateHealthColor
	Health.UpdatePredictionSize = nop -- don't let oUF mess with sizes
	self.Health = Health

	local DamageAbsorb = Health:CreateStatusBar()
	DamageAbsorb:SetPoint('TOP')
	DamageAbsorb:SetPoint('BOTTOM')
	DamageAbsorb:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	DamageAbsorb:SetWidth(SCALED_WIDTH)
	DamageAbsorb:SetStatusBarColor(addon.colors.absorb:GetRGB())
	Health.DamageAbsorb = DamageAbsorb

	local HealthValue = Health:CreateText()
	HealthValue:SetPoint('RIGHT', Health, -3, -1)
	HealthValue:SetJustifyH('RIGHT')
	HealthValue:SetSmoothScaling(true)
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
	Name:SetPoint('LEFT', Health, 4, -1)
	Name:SetPoint('RIGHT', HealthValue, 'LEFT', 1, 0)
	Name:SetJustifyH('LEFT')
	Name:SetSmoothScaling(true)
	self.Name = Name
	self:Tag(Name, '[inomena:quest][inomena:nameplatecolor][inomena:name<$|r]')

	local FriendlyName = self:CreateText(14)
	FriendlyName:SetPoint('CENTER')
	FriendlyName:SetJustifyH('CENTER')
	FriendlyName:SetSmoothScaling(true)
	self.FriendlyName = FriendlyName
	self:Tag(FriendlyName, '[inomena:afk][inomena:reactioncolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP', 0, addon.SPACING)
	RaidIcon:SetSize(30, 30)
	self.RaidTargetIndicator = RaidIcon

	local PetIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	PetIcon:SetPoint('CENTER', Health, 'BOTTOMLEFT')
	PetIcon:SetAtlas('wildbattlepetcapturable')
	PetIcon:SetSize(12, 12)
	self.PetIcon = PetIcon

	local EliteIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	EliteIcon:SetPoint('CENTER', Health)
	EliteIcon:SetAtlas('Islands-AzeriteBoss')
	EliteIcon:SetSize(30, 30)
	self.EliteIcon = EliteIcon

	local Buffs = self:CreateAuras({
		layoutLimit = 95, -- will fit 2 emphasized or 3 non-emphasized
		growthX = 'LEFT',
		growthY = 'UP', -- default
		initialAnchor = 'BOTTOMRIGHT',
	})
	Buffs:SetPoint('BOTTOMRIGHT', Health, 'TOPRIGHT', 0, addon.SPACING)
	Buffs.disableCooldownText = true -- custom option
	Buffs.disableMouse = true
	Buffs.elementSpacing = addon.SPACING
	Buffs.lineSpacing = addon.SPACING
	Buffs.showCount = true
	Buffs.size = 28
	Buffs.PostCreateButton = addon.unitShared.PostCreateAura
	Buffs.dispelGroup = Buffs:AddGroup('HELPFUL', {
		showCustomBuffBorder = true,
		size = 40, -- emphasize!
	})
	Buffs.buffsGroup = Buffs:AddGroup('HELPFUL')
	self.Buffs = Buffs

	-- modify candidate filters based on dispel spells the player knows
	self:RegisterEvent('SPELLS_CHANGED', GenerateFlatClosure(updateBuffFilters, Buffs), true)
	updateBuffFilters(Buffs)

	local Debuffs = self:CreateAuras({
		layoutLimit = 135, -- 4 debuffs for each row
		growthX = 'RIGHT',
		growthY = 'UP', -- default
		initialAnchor = 'BOTTOMLEFT',
	})
	Debuffs:SetPoint('BOTTOMLEFT', Health, 'TOPLEFT', 0, addon.SPACING)
	Debuffs.disableCooldownText = true -- custom option
	Debuffs.disableMouse = true
	Debuffs.elementSpacing = addon.SPACING
	Debuffs.lineSpacing = addon.SPACING
	Debuffs.showCount = true
	Debuffs.size = 30
	Debuffs.PostCreateButton = addon.unitShared.PostCreateAura
	Debuffs:AddGroup('HARMFUL|PLAYER|!CROWD_CONTROL')
	self.Debuffs = Debuffs

	local CrowdControl = self:CreateAuras({
		growthX = 'RIGHT',
		initialAnchor = 'LEFT',
	})
	CrowdControl:SetPoint('LEFT', Health, 'RIGHT', addon.SPACING, 0)
	CrowdControl.centerCooldownText = true -- custom option
	CrowdControl.cooldownTextSize = 18 -- custom option
	CrowdControl.disableMouse = true
	CrowdControl.elementSpacing = addon.SPACING
	CrowdControl.lineSpacing = addon.SPACING
	CrowdControl.maxFrameCount = 3
	CrowdControl.showCount = true
	CrowdControl.size = 40
	CrowdControl.PostCreateButton = addon.unitShared.PostCreateAura
	CrowdControl:AddGroup('HARMFUL|CROWD_CONTROL', {
		hideDebuffBorder = true,
	})
	self.CrowdControl = CrowdControl

	local Castbar = Health:CreateBackdropStatusBar()
	Castbar:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, -1)
	Castbar:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -1)
	Castbar:SetHeight(20)
	Castbar:HookScript('OnShow', GenerateFlatClosure(updateOutlineAnchors, self))
	Castbar:HookScript('OnHide', GenerateFlatClosure(updateOutlineAnchors, self))
	Castbar.timeToHold = 2.5
	Castbar.PostCastStart = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterruptible = addon.unitShared.PostUpdateCast
	Castbar.PostCastInterrupted = addon.unitShared.PostInterruptedCast
	Castbar.PostCastFail = addon.unitShared.PostFailedCast
	self.Castbar = Castbar

	local CastbarInterruptible = Castbar:CreateTexture('OVERLAY', 1) -- level is important
	CastbarInterruptible:SetAllPoints(Castbar:GetStatusBarTexture())
	Castbar.Interruptible = CastbarInterruptible

	local CastbarShielded = Castbar:CreateTexture('OVERLAY', 2) -- level is important
	CastbarShielded:SetAllPoints(Castbar:GetStatusBarTexture())
	Castbar.Shielded = CastbarShielded

	local CastbarText = Castbar:CreateText(14)
	CastbarText:SetPoint('TOPLEFT', 0, 3)
	CastbarText:SetPoint('BOTTOMRIGHT', 0, -3)
	CastbarText:SetJustifyH('CENTER')
	CastbarText:SetFrameLevel(10)
	CastbarText:SetSmoothScaling(true)
	CastbarText:GetParent():SetClipsChildren(true)
	Castbar.Text = CastbarText

	local TargetOutline = addon:CreateOutline(Health)
	TargetOutline:SetColor(1, 1, 1)
	TargetOutline:Hide()
	self.TargetOutline = TargetOutline

	-- TODO: focus outline or something

	self:RegisterEvent('PLAYER_REGEN_DISABLED', updateOnAdded, true) -- for combat state changes
	self:RegisterEvent('PLAYER_REGEN_ENABLED', updateOnAdded, true) -- for combat state changes
	self:RegisterEvent('PLAYER_FOCUS_CHANGED', updateHealthColor, true)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', updateOnAdded, true)
	self:RegisterEvent('UNIT_FLAGS', updateOnAdded) -- for reaction state changes
	self:RegisterEvent('UNIT_FACTION', updateOnAdded) -- for reaction state changes
	self:RegisterEvent('UNIT_HEALTH', updateOnAdded) -- extra updates
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', updateHealthColor)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', updateHealthColor) -- unsure if needed
	addon:RegisterUnitEvent('UNIT_FLAGS', 'player', GenerateFlatClosure(updateOnAdded, self))
end)

oUF:SetActiveStyle(styleName)

local nameplates = oUF:SpawnNamePlates()
nameplates:SetAddedCallback(updateOnAdded)
nameplates:SetRemovedCallback(updateOnRemoved)
nameplates:SetFriendlyInteractible(false)

nameplates:SetCVars({
	-- from the settings, in order
	nameplateShowAll = 1,
	nameplateShowEnemies = 1,
	nameplateShowEnemyPets = 1,
	nameplateShowEnemyMinus = 1,
	-- nameplateShowFriendlyPlayers = 0,
	nameplateShowFriendlyPlayerMinions = 0,
	nameplateShowFriendlyPlayerPets = 0,
	nameplateShowFriendlyPlayerGuardians = 0,
	nameplateShowFriendlyPlayerTotems = 0,
	nameplateShowOnlyNameForFriendlyPlayerUnits = 1,
	nameplateUseClassColorForFriendlyPlayerUnitNames = 1,
	nameplateShowFriendlyRealmName = 0,
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
	nameplatePlayRemovalAnimation = 0,
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
	_G[fontObject]:SetFont(addon.FONT, 16, 'SLUG,OUTLINE')
end

-- hide realm names for friendly nameplates in instances,
-- the new "nameplateShowFriendlyRealmName" cvar will still append "(*)"
addon:SafeSetNil(NamePlateFriendlyFrameOptions, 'updateNameUsesGetUnitName')

-- auto-enable friendly player nameplates when in a dungeon
local function updateZone()
	C_CVar.SetCVar('nameplateShowFriendlyPlayers', addon:IsInDungeon() and 1 or 0)
end

addon:RegisterEvent('ZONE_CHANGED_NEW_AREA', updateZone)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateZone)
