local _, addon = ...
local oUF = addon.oUF

local function overrideDisplayPower(element, unit)
	-- only show power for healers' mana or blood death knights' runic power
	local self = element:GetParent()

	local role = UnitGroupRolesAssignedEnum(unit)
	if role == Enum.LFGRole.Healer then
		self.Health.TempLoss:SetHeight(self:GetHeight() - element:GetHeight() - 1)
		element:SetHeight(5)
		return Enum.PowerType.Mana
	elseif role == Enum.LFGRole.Tank then
		local _, classToken = UnitClass(unit)
		if classToken == 'DEATHKNIGHT' then
			self.Health.TempLoss:SetHeight(self:GetHeight() - element:GetHeight() - 1)
			element:SetHeight(5)

			return Enum.PowerType.RunicPower
		end
	end

	self.Health.TempLoss:SetHeight(self:GetHeight())
	element:SetHeight(0)
end

local function forceUpdatePower(self)
	self.Power:ForceUpdate()
end

local function updateBuffsCombat(element)
	-- there's no proper way to disable a group
	if UnitAffectingCombat('player') then
		element:SetAuraGroupMaxFrameCount(element.classBuffGroup, 0)
	else
		element:SetAuraGroupMaxFrameCount(element.classBuffGroup, 1)
	end
end

local classBuffs = {}; do
	for class, spellID in next, addon.CLASS_BUFF_SPELLS do
		if addon.PLAYER_CLASS == class then
			classBuffs[spellID] = true
		end
	end
end

local function postCreateDefensiveSlot(element, button)
	button:SetPoint('CENTER', element.__owner.Health)
end

local function style(self, unit, isRaidStyle)
	Mixin(self, addon.widgetMixin)

	self:SetScript('OnEnter', addon.unitShared.ShowTooltip)
	self:SetScript('OnLeave', addon.unitShared.HideTooltip)

	addon:DeferMethod(self, 'RegisterForClicks', 'AnyUp')
	addon.unitShared.AddShiftClick(self, unit)
	addon.unitShared.AddMiddleClick(self)
	addon:AddBackdrop(self)
	self:SetBackgroundColor(0, 0, 0, 0.7)

	local HealthTempLoss = self:CreateStatusBar()
	HealthTempLoss:SetPoint('TOPLEFT')
	HealthTempLoss:SetPoint('TOPRIGHT')
	HealthTempLoss:SetHeight(self:GetHeight())
	HealthTempLoss:SetReverseFill(true)
	HealthTempLoss:SetStatusBarTexture('UI-HUD-UnitFrame-Target-PortraitOn-Bar-TempHPLoss')

	local Health = self:CreateStatusBar()
	Health:SetPoint('TOPLEFT')
	Health:SetPoint('TOPRIGHT', HealthTempLoss:GetStatusBarTexture(), 'TOPLEFT')
	Health:SetPoint('BOTTOMRIGHT', HealthTempLoss:GetStatusBarTexture(), 'BOTTOMLEFT')
	Health.colorClass = true
	Health.colorDisconnected = true
	Health.colorReaction = true -- for vehicles
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

	local Power = self:CreateBackdropStatusBar()
	Power:SetPoint('BOTTOMLEFT')
	Power:SetPoint('BOTTOMRIGHT')
	Power:SetHeight(5)
	Power.colorPower = true
	Power.GetDisplayPower = overrideDisplayPower
	Power.displayAltPower = true -- needed for display override to work
	self.Power = Power

	-- update power whenever a player's role changes
	self:RegisterEvent('PLAYER_ROLES_ASSIGNED', forceUpdatePower, true)

	-- use a custom parent for name to prevent truncating
	local NameContainer = Health:CreateFrame('Frame')
	NameContainer:SetPoint('TOPLEFT', addon.SPACING, -addon.SPACING)
	NameContainer:SetPoint('BOTTOMRIGHT', -addon.SPACING, addon.SPACING)
	NameContainer:SetClipsChildren(true) -- first part of the trick
	NameContainer:SetFrameLevel(HealAbsorb:GetFrameLevel() + 1) -- render high

	local Name = Health:CreateText(14)
	Name:SetParent(NameContainer) -- second part of the trick
	Name:SetWidth(999) -- last part of the trick
	Name:SetPoint('LEFT')
	Name:SetJustifyH('LEFT')
	self.Name = Name
	self:Tag(Name, '[inomena:leader][inomena:reactioncolor][inomena:name<$|r]')

	local Status = Health:CreateText()
	Status:SetPoint('CENTER', Health, 'TOP', 0, -addon.SPACING)
	Status:SetJustifyH('CENTER')
	Status:SetIgnoreParentAlpha(true) -- so we can see status regardless of range
	self:Tag(Status, '[inomena:summon][inomena:resurrect][inomena:offline][inomena:dead]')

	local RaidIcon = Health:CreateTexture('OVERLAY')
	RaidIcon:SetPoint('CENTER', Health, 'TOP')
	RaidIcon:SetSize(20, 20)
	self.RaidTargetIndicator = RaidIcon

	local ReadyCheck = Health:CreateTexture('OVERLAY')
	ReadyCheck:SetPoint('TOPRIGHT', Health, addon.SPACING, addon.SPACING)
	ReadyCheck:SetSize(18, 18)
	ReadyCheck:SetIgnoreParentAlpha(true) -- so we can see status regardless of range
	self.ReadyCheckIndicator = ReadyCheck

	local Buffs = self:CreateAuras({
		layoutLimit = self:GetWidth() - 3,
		growthX = 'RIGHT',
		growthY = 'DOWN',
		initialAnchor = 'TOPLEFT',
	})
	Buffs:SetPoint('TOPLEFT', 3, -3)
	Buffs.disableCooldownText = true -- custom option
	Buffs.elementSpacing = addon.SPACING
	Buffs.lineSpacing = addon.SPACING
	Buffs.showCount = true
	Buffs.tooltipAnchor = 'ANCHOR_TOPRIGHT'
	Buffs.tooltipHideInCombat = true
	Buffs.tooltipOffsetX = 1
	Buffs.tooltipOffsetY = 3
	Buffs.PostCreateButton = addon.unitShared.PostCreateAura
	Buffs.classBuffGroup = Buffs:AddGroup('HELPFUL', {
		candidateFilters = {
			includeSpellIDs = classBuffs,
		},
	})
	Buffs:AddGroup('HELPFUL|PLAYER|RAID|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE', {
		candidateFilters = {
			excludeSpellIDs = classBuffs,
		},
	})
	Buffs:AddSlot('HELPFUL|BIG_DEFENSIVE', {
		-- I wish we could combine BIG_ and EXTERNAL_
		size = self:GetHeight() / 2,
		raiseLevels = 2,
		postCreateButton = postCreateDefensiveSlot,
	})
	Buffs:AddSlot('HELPFUL|EXTERNAL_DEFENSIVE', {
		size = self:GetHeight() / 2,
		raiseLevels = 3,
		postCreateButton = postCreateDefensiveSlot,
	})

	-- auto-hide class buffs in combat
	self:RegisterEvent('PLAYER_REGEN_DISABLED', GenerateFlatClosure(updateBuffsCombat, Buffs), true)
	self:RegisterEvent('PLAYER_REGEN_ENABLED', GenerateFlatClosure(updateBuffsCombat, Buffs), true)
	updateBuffsCombat(Buffs) -- so it works with reloading too

	local Debuffs = self:CreateAuras({
		layoutLimit = math.huge, -- never let them wrap
		growthX = isRaidStyle and 'LEFT' or 'RIGHT',
		initialAnchor = isRaidStyle and 'BOTTOMRIGHT' or 'LEFT',
	})
	Debuffs.disableCooldownText = isRaidStyle -- custom option
	Debuffs.elementSpacing = addon.SPACING
	Debuffs.lineSpacing = addon.SPACING
	Debuffs.maxFrameCount = isRaidStyle and 3 or math.huge
	Debuffs.showCount = true
	Debuffs.size = isRaidStyle and 16 or (self:GetHeight() * 2/3)
	Debuffs.tooltipAnchor = 'ANCHOR_TOPLEFT'
	Debuffs.tooltipOffsetX = -1
	Debuffs.tooltipOffsetY = 3
	Debuffs.PostCreateButton = addon.unitShared.PostCreateAura
	Debuffs.overlayGroup = Debuffs:AddSlot('HARMFUL|RAID', {
		CreateButton = addon.unitShared.CreateDispelOverlay,
	})

	if isRaidStyle then
		Debuffs:SetPoint('BOTTOMRIGHT', -3, 3)
		Debuffs:AddGroup('HARMFUL|CROWD_CONTROL', {
			size = 20 -- emphasize!
		})
		Debuffs:AddGroup('HARMFUL|!CROWD_CONTROL')
	else
		Debuffs:SetPoint('LEFT', self, 'RIGHT', addon.SPACING + 2, 0) -- extra 2px because of threat border
		Debuffs:AddGroup('HARMFUL')
	end

	local Phase = self:CreateFrame('Frame', 'InsecureMouseClicksPropagatorTemplate')
	Phase:SetSize(28, 28)
	Phase:SetPoint('CENTER')
	Phase:EnableMouse(true) -- for tooltips
	Phase:SetFrameLevel(10) -- above all else
	self.PhaseIndicator = Phase

	local PhaseIcon = Phase:CreateIcon()
	PhaseIcon:SetAllPoints()
	Phase.Icon = PhaseIcon

	local Threat = self:CreateFrame('Frame', 'BackdropTemplate')
	Threat:SetPoint('TOPLEFT', -5, 5)
	Threat:SetPoint('BOTTOMRIGHT', 5, -5)
	Threat:SetFrameStrata('BACKGROUND')
	Threat:SetBackdrop(addon.GLOW)
	Threat.PostUpdate = addon.unitShared.PostUpdateThreat
	self.ThreatIndicator = Threat

	self.Range = {
		outsideAlpha = 0.2,
	}
end

local partyStyle = addon.unitPrefix .. 'Party'
oUF:RegisterStyle(partyStyle, function(self, unit)
	style(self, unit, false)
end)

local raidStyle = addon.unitPrefix .. 'Raid'
oUF:RegisterStyle(raidStyle, function(self, unit)
	style(self, unit, true)
end)

oUF:Factory(function(self)
	local sharedAttributes = {
		groupBy = 'ASSIGNEDROLE',
		groupingOrder = 'TANK,HEALER,DAMAGER',
		columnAnchorPoint = 'RIGHT',
		columnSpacing = addon.SPACING,
		unitsPerColumn = 5,
		point = 'TOP',
		yOffset = -addon.SPACING,
	}

	local function SpawnHeader(styleName, role, attributes, ...)
		local visibleSpecs = addon:T()
		for specIndex, specRole in next, addon.CLASS_SPECIALIZATION_ROLE[addon.PLAYER_CLASS] do
			if role:sub(1, 1) == '!' then
				if specRole ~= role:sub(2) then
					visibleSpecs:insert(specIndex)
				end
			elseif specRole == role then
				visibleSpecs:insert(specIndex)
			end
		end

		if #visibleSpecs == 0 then
			return
		end

		self:SetActiveStyle(styleName)

		local header = self:SpawnHeader(nil, nil, attributes:merge(sharedAttributes))
		header:SetPoint(...)
		addon:PixelPerfect(header)

		local visibility
		if attributes.showRaid then
			visibility = 'custom [group:raid,spec:%s] show; hide'
		else
			visibility = 'custom [group:party,nogroup:raid,spec:%s] show; hide'
		end

		header:SetVisibility(visibility:format(visibleSpecs:concat('/')))
	end

	-- same party frames for all roles, so we use a fake negative role to match all roles
	SpawnHeader(partyStyle, '!ALL', addon:T({
		showParty = true,
		showPlayer = true,
		maxColumns = 1,
		['oUF-initialConfigFunction'] = [[
			self:SetWidth(144)
			self:SetHeight(52)
		]]
	}), 'RIGHT', UIParent, 'CENTER', -360, 0)

	-- healer-specific raid
	SpawnHeader(raidStyle, 'HEALER', addon:T({
		showRaid = true,
		maxColumns = 8,
		['oUF-initialConfigFunction'] = [[
			self:SetWidth(92)
			self:SetHeight(48)
		]]
	}), 'RIGHT', UIParent, 'CENTER', -300, 0)

	-- dmg & tank use the same raid layout
	SpawnHeader(raidStyle, '!HEALER', addon:T({
		showRaid = true,
		maxColumns = 8,
		['oUF-initialConfigFunction'] = [[
			self:SetWidth(80)
			self:SetHeight(40)
		]]
	}), 'RIGHT', UIParent, 'CENTER', -500, -90)
end)
