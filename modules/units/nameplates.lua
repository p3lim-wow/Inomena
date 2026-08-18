local _, addon = ...
local oUF = addon.oUF


local function updateOutlineAnchors(self)
	if self.Castbar:IsShown() then
		self.TargetOutline:SetPoint('BOTTOM', self.Castbar, 0, -4)
		self.TargetOutline.edges.Bottom:SetPoint('TOP', self.Castbar, 'BOTTOM')
	else
		self.TargetOutline:SetPoint('BOTTOM', self.Health, 0, -4)
		self.TargetOutline.edges.Bottom:SetPoint('TOP', self.Health, 'BOTTOM')
	end
end

local function updateOnAdded(self)
	local unit = self.__unit
	if not UnitCanAttack('player', unit) then
		-- name-only
		self.Name:ClearAllPoints()
		self.Name:SetPoint('CENTER')
		self.Name:SetJustifyH('CENTER')
		self.Name:Show()

		-- pause elements to hide them
		self:PauseElement('Health')
		self:PauseElement('Auras')
		self:PauseElement('Castbar')
		return
	else
		self.Name:ClearAllPoints()
		self.Name:SetPoint('LEFT', self.Health, 4, -1)
		self.Name:SetPoint('RIGHT', self.HealthValue, 'LEFT', 1, 0)
		self.Name:SetJustifyH('LEFT')
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
		self.Health:SetHeight(28)
		self.HealthValue:Show()
	else
		self.Health:SetHeight(4)
		self.HealthValue:Hide()
	end

	updateOutlineAnchors(self)

	self.PetIcon:SetShown(UnitIsOtherPlayersPet(unit))

	self.Health:SetFrameLevel(4)
	self.Name:SetFrameLevel(5)

	-- we need to force-update the health sub-widgets one frame after they've been initialized by
	-- UAE because the game rendering engine will have incorrect sizes for them during creation with
	-- a custom scale (which we apply with our PixelPerfect method during spawn). Blizzard is aware
	-- of this bug, but they don't really have a solution for it.
	C_Timer.After(0, GenerateClosure(self.Health.ForceUpdate, self.Health))
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

local function setBounds(self)
	-- nameplates take up the space by the visibile anchored children by default, which changes
	-- whenever we alter the health size, the castbar shows up, or buffs/debuffs gets added or
	-- removed, resulting in a "bouncy" nameplate.
	-- to prevent this we add a static frame to use as our bounds
	local bounds = CreateFrame('Frame', nil, self)
	bounds:SetAllPoints()

	-- however, this still only works when there's something occupying the bounds frame, so we'll
	-- add a texture to it but make it fully transparent
	local filler = bounds:CreateTexture()
	filler:SetAllPoints()
	filler:SetColorTexture(0, 0, 0, 0)

	self:GetParent():SetStackingBoundsFrame(bounds)
end

local styleName = addon.unitPrefix .. 'NamePlates'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	addon:PixelPerfect(self)

	setBounds(self)

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

	local Name = self:CreateText(14)
	Name:SetPoint('LEFT', Health, 4, -1)
	Name:SetPoint('RIGHT', HealthValue, 'LEFT', 1, 0)
	Name:SetJustifyH('LEFT')
	Name:SetWordWrap(false)
	Name:SetSmoothScaling(true)
	Name:GetParent():SetFrameLevel(20) -- above everything else
	self.Name = Name
	self:Tag(Name, '[inomena:quest]|cffffce18[inomena:away]|r[inomena:nameplatecolor][inomena:name<$|r]')

	local RaidIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	RaidIcon:SetPoint('CENTER', Health, 'TOP', 0, addon.SPACING)
	RaidIcon:SetSize(30, 30)
	self.RaidTargetIndicator = RaidIcon

	local PetIcon = HealthValue:GetParent():CreateTexture('OVERLAY') -- higher parent
	PetIcon:SetPoint('CENTER', Health, 'BOTTOMLEFT')
	PetIcon:SetAtlas('wildbattlepetcapturable')
	PetIcon:SetSize(12, 12)
	self.PetIcon = PetIcon

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
nameplates:SetSize(200, 50) -- we keep it wide just because of stupid long names, no other reason
nameplates:SetFriendlyInteractible(false)

nameplates:SetCVars({
	-- from the settings, in order
	nameplateShowAll = 1,
	nameplateShowEnemies = 1,
	nameplateShowEnemyPets = 1,
	nameplateShowEnemyMinus = 1,
	-- nameplateShowFriendlyPlayers = 0,
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
	nameplateShowOnlyNameForFriendlyPlayerUnits = 1, -- for friendly nameplates in dungeons
	nameplateUseClassColorForFriendlyPlayerUnitNames = 1, -- for friendly nameplates in dungeons
	nameplateShowFriendlyRealmName = 0, -- for friendly nameplates in dungeons
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
