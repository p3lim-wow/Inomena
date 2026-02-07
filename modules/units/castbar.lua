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
	if owner.unit == 'player' then
		return owner.unit == unit or owner.realUnit == unit
	elseif owner.unit == 'pet' then
		return UnitIsPossessed(unit)
	end
end

local function postStartCast(element)
	element:SetStatusBarColor(1, 1, 1) -- need to reset here after fake GCDs
end

local timer
local function resetCastbar(element)
	if not element.castID then -- don't reset if it's in use
		element.channeling = nil
		element:Hide()
		timer = nil
	end
end

local function updateGlobalCooldown(self)
	local element = self.Castbar
	if element.castID then
		return
	end

	local info = C_Spell.GetSpellCooldown(61304) -- super secret GCD spell, never secret
	if info and info.duration > 0 then
		-- reset manually
		element.castID = nil
		element.delay = 0
		if timer then
			timer:Cancel()
		end

		-- fake channeling
		element.channeling = true

		-- special color
		element:SetStatusBarColor(0, 0.5, 1)

		-- generate duration from spell info
		local duration = C_DurationUtil.CreateDuration()
		duration:SetTimeFromStart(GetTime(), info.duration, info.modRate)

		-- render duration on castbar
		element:SetTimerDuration(duration, element.smoothing, Enum.StatusBarTimerDirection.RemainingTime)
		element:Show()

		-- reset after duration ends
		timer = C_Timer.NewTimer(info.duration, GenerateClosure(resetCastbar, element))
	end
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
	self.Castbar = Castbar

	local CastbarTime = Castbar:CreateText()
	CastbarTime:SetPoint('CENTER')
	CastbarTime:SetJustifyH('CENTER')
	Castbar.Time = CastbarTime

	if unit == 'player' then
		-- display global cooldown from instant casts as a fake channel spell
		self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', updateGlobalCooldown)
	end
end)

oUF:SetActiveStyle(styleName)

-- pet castbar overlapping for vehicle/possess support
for _, unit in next, {'player', 'pet'} do
	local castbar = oUF:Spawn(unit, styleName .. unit:gsub('^%l', string.upper))
	castbar:SetPoint('TOP', addon.units.resources, 'BOTTOM', 0, -addon.SPACING)
	addon:PixelPerfect(castbar)
end
