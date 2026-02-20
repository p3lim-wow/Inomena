local _, addon = ...
local oUF = addon.oUF

local function overrideDisplayPower(element, unit)
	-- only show power for healers' mana or blood death knights' runic power
	local self = element:GetParent()

	local role = UnitGroupRolesAssigned(unit)
	if role == 'HEALER' then
		if UnitPowerType(unit) == Enum.PowerType.Mana then
			self:EnableElement('Power')
			self.Health:SetHeight(self:GetHeight() - element:GetHeight() - 1)

			return Enum.PowerType.Mana
		end
	elseif role == 'TANK' then
		local _, classToken = UnitClass(unit)
		if classToken == 'DEATHKNIGHT' then
			self:EnableElement('Power')
			self.Health:SetHeight(self:GetHeight() - element:GetHeight() - 1)

			return Enum.PowerType.RunicPower
		end
	end

	self:DisableElement('Power')
	self.Health:SetHeight(self:GetHeight())
end

local function wrapForceUpdatePower(self)
	self.Power:ForceUpdate()
end

local function postCreateBuff(_, Button)
	-- make buffs a little more eligible since they're small
	Button.Count:ClearAllPoints()
	Button.Count:SetPoint('CENTER', Button, 'BOTTOM', 1, -1)
	Button.Count:SetJustifyH('CENTER')
end

local filterBuffs, filterDefensiveBuffs; do
	local function matches(filter, unit, data) -- shorthand
		return not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, filter)
	end

	function filterBuffs(_, ...)
		-- we want to see our applied buffs, but not defensives since that's separate
		if UnitAffectingCombat('player') then
			-- filter out useless auras during combat, like class raid buffs
			return matches('HELPFUL|PLAYER|RAID_IN_COMBAT', ...) and not matches('HELPFUL|BIG_DEFENSIVE', ...) and not matches('HELPFUL|EXTERNAL_DEFENSIVE', ...)
		end
		return matches('HELPFUL|PLAYER|RAID', ...) and not matches('HELPFUL|BIG_DEFENSIVE', ...) and not matches('HELPFUL|EXTERNAL_DEFENSIVE', ...)
	end

	function filterDefensiveBuffs(_, ...)
		return matches('HELPFUL|BIG_DEFENSIVE', ...) or matches('HELPFUL|EXTERNAL_DEFENSIVE', ...)
	end
end

local function updateCombat(self)
	-- update buffs to force refresh our filters when combat changes
	self.Buffs:ForceUpdate()
end

local function style(self, unit)
	Mixin(self, addon.widgetMixin)

	self:SetScript('OnEnter', addon.unitShared.ShowTooltip)
	self:SetScript('OnLeave', addon.unitShared.HideTooltip)

	addon:DeferMethod(self, 'RegisterForClicks', 'AnyUp')
	addon.unitShared.AddShiftClick(self, unit)
	addon.unitShared.AddMiddleClick(self)
	addon:AddBackdrop(self)
	self:SetBackgroundColor(0, 0, 0, 0.7)

	local Health = self:CreateStatusBar()
	Health:SetPoint('TOPLEFT')
	Health:SetPoint('TOPRIGHT')
	Health:SetHeight(self:GetHeight())
	Health.colorClass = true
	Health.colorDisconnected = true
	Health.colorReaction = true -- for vehicles
	Health.incomingHealOverflow = 1
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
	self:RegisterEvent('PLAYER_ROLES_ASSIGNED', wrapForceUpdatePower, true)

	-- use a custom parent for name to prevent truncating
	local NameContainer = Health:CreateFrame('Frame')
	NameContainer:SetPoint('TOPLEFT', addon.SPACING, -addon.SPACING)
	NameContainer:SetPoint('BOTTOMRIGHT', -addon.SPACING, addon.SPACING)
	NameContainer:SetClipsChildren(true) -- first part of the trick

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

	local Buffs = self:CreateFrame()
	Buffs:SetPoint('TOPLEFT', 3, -3)
	Buffs:SetSize(self:GetWidth() - 3, 18)
	Buffs:SetFrameLevel(Name:GetParent():GetFrameLevel() + 1) -- render high
	Buffs.growthX = 'RIGHT'
	Buffs.growthY = 'DOWN'
	Buffs.size = 16
	Buffs.spacing = addon.SPACING
	Buffs.initialAnchor = 'TOPLEFT'
	Buffs.disableCooldownText = true -- custom option
	Buffs.filter = 'HELPFUL|PLAYER' -- we filter it further in FilterAura override
	Buffs.CreateButton = addon.unitShared.CreateAura
	Buffs.PostCreateButton = postCreateBuff
	Buffs.FilterAura = filterBuffs
	self.Buffs = Buffs

	-- force update auras on combat state change for filters
	self:RegisterEvent('PLAYER_REGEN_DISABLED', updateCombat, true)
	self:RegisterEvent('PLAYER_REGEN_ENABLED', updateCombat, true)

	local Debuffs = self:CreateFrame()
	Debuffs.growthY = 'DOWN'
	Debuffs.spacing = addon.SPACING
	Debuffs.maxCols = 99 -- make sure it never wraps
	Debuffs.CreateButton = addon.unitShared.CreateAura
	Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	Debuffs.PostUpdate = addon.unitShared.PostUpdateAuras
	self.Debuffs = Debuffs

	local DefensiveBuffs = self:CreateFrame()
	DefensiveBuffs:SetPoint('CENTER')
	DefensiveBuffs:SetSize(self:GetHeight() / 2, self:GetHeight() / 2)
	DefensiveBuffs:SetFrameLevel(Name:GetParent():GetFrameLevel() + 2) -- render high
	DefensiveBuffs.size = self:GetHeight() / 2
	DefensiveBuffs.initialAnchor = 'CENTER'
	DefensiveBuffs.numBuffs = 1
	DefensiveBuffs.numDebuffs = 0
	DefensiveBuffs.disableCooldownText = true -- custom option
	DefensiveBuffs.buffFilter = 'HELPFUL' -- we filter it further in FilterAura override
	DefensiveBuffs.CreateButton = addon.unitShared.CreateAura
	DefensiveBuffs.FilterAura = filterDefensiveBuffs
	self.Auras = DefensiveBuffs

	local PrivateAuras = self:CreateFrame()
	PrivateAuras.spacing = addon.SPACING
	PrivateAuras.maxCols = 99 -- make sure it never wraps
	self.PrivateAuras = PrivateAuras

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
	style(self, unit)

	-- debuffs outside to the right
	self.Debuffs.filter = 'HARMFUL'
	self.Debuffs.size = self:GetHeight() * 2/3
	self.Debuffs.growthX = 'RIGHT'
	self.Debuffs.initialAnchor = 'LEFT'
	self.Debuffs:SetPoint('LEFT', self, 'RIGHT', addon.SPACING, 0)
	self.Debuffs:SetHeight(self.Debuffs.size)

	self.PrivateAuras:SetPoint('LEFT', self.Debuffs, 'RIGHT', -1, 0) -- god knows if this is safe
	self.PrivateAuras:SetSize(self:GetWidth(), self.Debuffs:GetHeight())
	self.PrivateAuras.size = self.Debuffs.size
	self.PrivateAuras.growthX = self.Debuffs.growthX
	self.PrivateAuras.initialAnchor = self.Debuffs.initialAnchor
	self.PrivateAuras.borderScale = 2.5
end)

local raidStyle = addon.unitPrefix .. 'Raid'
oUF:RegisterStyle(raidStyle, function(self, unit)
	style(self, unit)

	-- debuffs inside the raid frame
	self.Debuffs.filter = 'HARMFUL'
	self.Debuffs.size = 16
	self.Debuffs.num = 3
	self.Debuffs.growthX = 'LEFT'
	self.Debuffs.initialAnchor = 'BOTTOMRIGHT'
	self.Debuffs.disableCooldownText = true -- custom option
	self.Debuffs:SetPoint('BOTTOMRIGHT', -3, 3)
	self.Debuffs:SetSize(self:GetWidth(), self.Debuffs.size)
	self.Debuffs:SetFrameLevel(self.Name:GetParent():GetFrameLevel() + 1) -- render high

	self.PrivateAuras:SetPoint('TOPRIGHT', -2, -4)
	self.PrivateAuras:SetSize(self:GetWidth(), self.Debuffs:GetHeight())
	self.PrivateAuras.spacing = 3
	self.PrivateAuras.size = self.Debuffs.size + 3
	self.PrivateAuras.growthX = self.Debuffs.growthX
	self.PrivateAuras.initialAnchor = self.Debuffs.initialAnchor
	self.PrivateAuras.disableCooldownText = self.Debuffs.disableCooldownText
	self.PrivateAuras.borderScale = 1
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
