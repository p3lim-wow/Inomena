local _, addon = ...
local oUF = addon.oUF

local function overrideDisplayPower(element, unit)
	-- only show power for healers' mana or blood death knights
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
	Button.Time:Hide()
	Button.Count:ClearAllPoints()
	Button.Count:SetPoint('CENTER', Button, 'BOTTOM', 1, -1)
	Button.Count:SetJustifyH('CENTER')
end

local function style(self, unit)
	Mixin(self, addon.widgetMixin)

	self:SetScript('OnEnter', addon.unitShared.Tooltip)
	self:SetScript('OnLeave', GameTooltip_Hide)

	addon:DeferMethod(self, 'RegisterForClicks', 'AnyUp')
	addon.unitShared.AddShiftClick(self, unit)
	addon.unitShared.AddMiddleClick(self)
	addon:AddBackdrop(self)

	local Health = self:CreateStatusBar()
	Health:SetPoint('TOPLEFT')
	Health:SetPoint('TOPRIGHT')
	Health:SetHeight(self:GetHeight())
	Health.colorClass = true
	Health.colorDisconnected = true
	Health.colorReaction = true -- for vehicles
	self.Health = Health

	self.HealthPrediction = {}
	self.HealthPrediction.incomingHealOverflow = 1 -- don't let it escape bounds

	local HealingPrediction = Health:CreateStatusBar()
	HealingPrediction:SetPoint('TOP')
	HealingPrediction:SetPoint('BOTTOM')
	HealingPrediction:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	HealingPrediction:SetWidth(self:GetWidth())
	HealingPrediction:SetStatusBarColor(140/255, 1, 46/255, 0.5)
	self.HealthPrediction.healingAll = HealingPrediction

	local DamageAbsorb = Health:CreateStatusBar()
	DamageAbsorb:SetPoint('TOP')
	DamageAbsorb:SetPoint('BOTTOM')
	DamageAbsorb:SetPoint('LEFT', HealingPrediction:GetStatusBarTexture(), 'RIGHT')
	DamageAbsorb:SetWidth(self:GetWidth())
	DamageAbsorb:SetStatusBarColor(67/255, 235/255, 231/255)
	self.HealthPrediction.damageAbsorb = DamageAbsorb

	local HealAbsorb = Health:CreateStatusBar()
	HealAbsorb:SetPoint('TOP')
	HealAbsorb:SetPoint('BOTTOM')
	HealAbsorb:SetPoint('RIGHT', Health:GetStatusBarTexture())
	HealAbsorb:SetWidth(self:GetWidth())
	HealAbsorb:SetReverseFill(true)
	HealAbsorb:SetStatusBarColor(0, 0, 0, 0.5)
	self.HealthPrediction.healAbsorb = HealAbsorb

	local OverHealAbsorbIndicator = Health:CreateTexture()
	OverHealAbsorbIndicator:SetPoint('TOP', Health, 0, 2)
	OverHealAbsorbIndicator:SetPoint('BOTTOM', Health, 0, -2)
	OverHealAbsorbIndicator:SetPoint('RIGHT', Health, 'LEFT', 3, 0)
	OverHealAbsorbIndicator:SetWidth(10)
	self.HealthPrediction.OverHealAbsorbIndicator = OverHealAbsorbIndicator

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
	Buffs.filter = 'HELPFUL|PLAYER|RAID'
	Buffs.CreateButton = addon.unitShared.CreateAura
	Buffs.PostCreateButton = postCreateBuff
	self.Buffs = Buffs

	local Debuffs = self:CreateFrame()
	Debuffs.growthY = 'DOWN'
	Debuffs.spacing = addon.SPACING
	Debuffs.maxCols = 99 -- make sure it never wraps
	Debuffs.CreateButton = addon.unitShared.CreateAura
	Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	Debuffs.PostUpdate = addon.unitShared.PostUpdateAuras
	self.Debuffs = Debuffs

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
	self.Debuffs.disableCooldownText = true
	self.Debuffs:SetPoint('BOTTOMRIGHT', -3, 3)
	self.Debuffs:SetSize(self:GetWidth(), self.Debuffs.size)
	self.Debuffs:SetFrameLevel(self.Name:GetParent():GetFrameLevel() + 1) -- render high
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
			self:SetWidth(60)
			self:SetHeight(30)
		]]
	}), 'RIGHT', UIParent, 'CENTER', -500, -102)
end)
