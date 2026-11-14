local _, addon = ...
local oUF = addon.oUF

local function overrideCreatePip(element)
	local pip = element:CreateTexture('OVERLAY')
	pip:SetSize(2, element:GetHeight())
	pip:SetColorTexture(0, 0, 0)
	return pip
end

local function overrideCastbarVisibility(element, unit)
	-- the two castbars to overlap, so only use the pet castbar for possess
	local owner = element.__owner
	if owner.__unit == 'player' then
		return owner.__unit == unit or owner.__realUnit == unit
	elseif owner.__unit == 'pet' then
		return UnitIsPossessed(unit)
	end
end

local function postStartCast(element, _, notInterruptible)
	element:SetStatusBarColorFromBoolean(notInterruptible, addon.colors.cast.shielded, addon.colors.cast.normal)
end

local function postGlobalCast(element)
	element:SetStatusBarColor(addon.colors.cast.global:GetRGB())
end

local styleName = addon.unitPrefix .. 'Castbar'
oUF:RegisterStyle(styleName, function(self, unit)
	Mixin(self, addon.widgetMixin)

	self:SetSize(310, 1)
	self:EnableMouse(false) -- non-interactable

	local Castbar = self:CreateBackdropStatusBar()
	Castbar:SetPoint('TOPLEFT')
	Castbar:SetPoint('TOPRIGHT')
	Castbar:SetHeight(12)
	Castbar:SetBackgroundColor(1/4, 1/4, 1/4)
	Castbar.PostCastStart = postStartCast
	Castbar.ShouldShow = overrideCastbarVisibility
	Castbar.CreatePip = overrideCreatePip
	Castbar.showGlobalCooldown = true
	Castbar.PostCastGlobal = postGlobalCast
	self.Castbar = Castbar

	local CastbarTime = Castbar:CreateText()
	CastbarTime:SetPoint('CENTER')
	CastbarTime:SetJustifyH('CENTER')
	Castbar.Time = CastbarTime

	local CastbarDelay = Castbar:CreateText()
	CastbarDelay:SetPoint('LEFT', CastbarTime, 'RIGHT')
	CastbarDelay:SetJustifyH('LEFT')
	CastbarDelay:SetTextColor(1, 0, 0)
	Castbar.Delay = CastbarDelay

	if addon:IsForever() then
		local Swing = self:CreateSwingElement(Enum.PlayerSwingType.Ranged)
		Swing:SetPoint('TOPLEFT', Castbar, 'BOTTOMLEFT', 0, -addon.SPACING)
		Swing:SetPoint('TOPRIGHT', Castbar, 'BOTTOMRIGHT', 0, -addon.SPACING)
		Swing:SetHeight(12)
		Swing:SetStatusBarTexture(addon.TEXTURE)
		Swing:SetStatusBarColor(addon.colors.swing.ranged:GetRGB())
		Swing.direction = Enum.StatusBarTimerDirection.RemainingTime
		addon:AddBackdrop(Swing)

		local SwingTime = addon.widgetMixin.CreateText(Swing)
		SwingTime:SetPoint('CENTER')
		SwingTime:SetJustifyH('CENTER')
		Swing.Time = SwingTime
	end
end)

oUF:SetActiveStyle(styleName)

-- pet castbar overlapping for vehicle/possess support
local castbars = {}
for _, unit in next, {'player', 'pet'} do
	local castbar = oUF:Spawn(unit, styleName .. unit:gsub('^%l', string.upper))
	castbar:SetPoint('TOP', addon.units.resources, 'BOTTOM', 0, -addon.SPACING)
	addon:PixelPerfect(castbar)
	castbars[unit] = castbar
end

addon:RegisterCallback('PlayerSpellsFrame.TalentTab.Show', function()
	if not InCombatLockdown() then
		for _, castbar in next, castbars do
			castbar:SetFrameStrata('DIALOG')
		end
	end
end)

addon:RegisterCallback('PlayerSpellsFrame.TalentTab.Hide', function()
	if not InCombatLockdown() then
		for _, castbar in next, castbars do
			castbar:SetFrameStrata('LOW')
		end
	end
end)
