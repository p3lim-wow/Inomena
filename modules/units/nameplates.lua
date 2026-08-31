local _, addon = ...
local oUF = addon.oUF

local function updateOutlineAnchors(self)
	local relative = self.Castbar:IsShown() and self.Castbar or self.Health
	self.TargetOutline:SetPoint('BOTTOM', relative, 0, -4)
	self.TargetOutline.edges.Bottom:SetPoint('TOP', relative, 'BOTTOM')
end

local function isInvalidPvPUnit(unit)
	return (UnitIsPlayer(unit) or UnitIsOtherPlayersPet(unit))
		and UnitReaction(unit, 'player') < 4
		and not (GetPVPDesired() or IsPVPTimerRunning() or C_PvP.IsWarModeDesired())
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
	end

	local isTarget = UnitIsUnit(unit, 'target')
	if not isTarget and not addon:IsInDungeon() and isInvalidPvPUnit(unit) then
		-- "hide" nameplates for units with PvP enabled when the player doesn't
		-- (this is something Blizzard should handle tbh)
		self:PauseAllElements()
		return
	end

	self:ResumeAllElements()

	local fullSize = IsInInstance() or UnitThreatSituation('player', unit) or isTarget
	local classification = UnitClassification(unit)
	if classification == 'minus' and not isTarget then
		-- trivial mobs should be small unless targeted
		fullSize = false
	end

	if addon:IsInDungeon() and not isTarget then
		local reaction = UnitReaction('player', unit)
		if reaction and reaction == 4 then
			-- neutral mobs should be small unless targeted
			fullSize = false
		end
	end

	local isQuest = C_QuestLog.UnitIsRelatedToActiveQuest(unit)
	local isRare = classification == 'rare' or classification == 'rareelite'
	self.Name:SetShown(isQuest or isRare or fullSize)
	self.FriendlyName:Hide()
	self.PetIcon:SetShown(UnitIsOtherPlayersPet(unit))
	self.EliteIcon:SetShown(classification == 'elite' and not fullSize)
	self.TargetOutline:SetShown(isTarget)

	local auraOffset = isTarget and 3 or 0
	self.Buffs:SetPointsOffset(auraOffset, addon.SPACING + auraOffset)
	self.Debuffs:SetPointsOffset(-auraOffset, addon.SPACING + auraOffset)
	self.CrowdControl:SetPointsOffset(addon.SPACING + auraOffset, 0)
	self.HealthValue:SetShown(fullSize)
	self.Health:SetHeight(fullSize and 28 or 4)

	if isTarget then
		updateOutlineAnchors(self)
	end
end

local function updateOnRemoved(self)
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
		unit = self.__unit
	elseif not unit or unit ~= self.__unit then
		return
	end

	if addon:IsInDungeon() then
		local color
		local groupRole = UnitGroupRolesAssignedEnum('player')
		if groupRole >= 0 then -- no role = -1, missing enum value
			local threatStatus = UnitThreatSituation('player', unit)
			color = addon.unitShared.GetThreatColor(groupRole, threatStatus)
		end

		if not color then
			local reaction = UnitReaction('player', unit)
			if reaction and reaction == 4 then
				-- color neutral mobs differently
				color = addon.colors.grey
			end
		end

		if not color then
			color = addon.colors.nameplate
		end

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

	if UnitIsPlayer(element.__owner.__unit) or UnitCanAssist('player', element.__owner.__unit, true, true) then
		element:SetAuraGroupMaxFrameCount(element.buffsGroup, 3)
	else
		element:SetAuraGroupMaxFrameCount(element.buffsGroup, 20)
	end
end

local styleName = addon.unitPrefix .. 'NamePlates'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	-- nameplates take up the space by the visible anchored children by default, which changes
	-- whenever we alter the health size, the castbar shows up, or buffs/debuffs gets added or
	-- removed, resulting in a "bouncy" nameplate.
	-- to prevent this we add a static frame to use as our bounds
	local bounds = CreateFrame('Frame', nil, self:GetParent())
	bounds:SetAllPoints()
	self:GetParent():SetStackingBoundsFrame(bounds)

	-- however, this still only works when there's something occupying the bounds frame, so we'll
	-- add a texture to it but make it fully transparent
	local filler = bounds:CreateTexture()
	filler:SetAllPoints()
	filler:SetColorTexture(0, 0, 0, 0)

	addon:PixelPerfect(self)

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
	DamageAbsorb:SetPoint('TOP', Health:GetStatusBarTexture())
	DamageAbsorb:SetPoint('BOTTOM', Health:GetStatusBarTexture())
	DamageAbsorb:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	DamageAbsorb:SetWidth(self:GetWidth() * UIParent:GetScale())
	DamageAbsorb:SetStatusBarColor(addon.colors.absorb:GetRGB())
	Health.DamageAbsorb = DamageAbsorb

	local HealthValue = Health:CreateText()
	HealthValue:SetPoint('RIGHT', Health, -3, -1)
	HealthValue:SetJustifyH('RIGHT')
	HealthValue:SetSmoothScaling(true)
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
	Name:SetFrameLevel(10)
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
	Buffs.PostUpdate = updateBuffFilters
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
nameplates:SetSize(200, 50) -- extra height for spacing
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

	-- most of the remaining settings only affect the visibility of default nameplate
	-- elements, which have no effect in oUF, but we'll manage the settings that do
	nameplateSize = Enum.NamePlateSize.Medium,
	nameplateStyle = Enum.NamePlateStyle.Modern,
	nameplateAuraScale = 0.70, -- can't go lower, higher increases nameplate vertical offset
	nameplateDebuffPadding = 0, -- this messes with offsets

	-- hidden cvars
	nameplatePlayRemovalAnimation = 0,
	nameplateMinAlpha = 1.0,
	nameplateOccludedAlphaMult = 0.3, -- line of sight based alpha
	nameplateMinScale = 1.0,
	nameplateSelectedScale = 1.0,
	nameplateTargetBehindMaxDistance = 30,
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
