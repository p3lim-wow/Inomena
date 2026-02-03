local addonName, addon = ...

-- skin opie

local CIRCLE_BORDER = addon.PATH .. 'circle'
local CIRCLE_MASK = [[Interface\CharacterFrame\TempPortraitAlphaMask]]

local methods = {
	-- SetActive = nop, -- (active)
	SetBinding = nop, -- (binding)
	-- SetCooldown = nop, -- (remain, duration, usable)
	-- SetCooldownPH = nop, -- (hintID, qf, _holdCount)
	SetCooldownTextShown = nop, -- (cooldownShown, rechargeShown)
	SetCount = nop, -- (count)
	-- SetDominantColor = nop, -- (r,g,b)
	SetEquipState = nop, -- (isInContainer, isInInventory)
	-- SetHighlighted = nop, -- (highlight)
	-- SetIcon = nop, -- (texture, aspect)
	-- SetIconAtlas = nop, -- (atlas, aspect)
	SetIconTexCoord = nop, -- (a,b,c,dc, e,f,g,h)
	-- SetIconVertexColor = nop, -- (r,g,b)
	SetOuterGlow = nop, -- (shown)
	SetOverlayIcon = nop, -- (tex, w, h, ...)
	SetOverlayIconVertexColor = nop, -- (...)
	SetQualityOverlay = nop, -- (qual)
	SetShortLabel = nop, -- (text)
	SetUsable = nop, -- (usable, _usableCharge, _cd, nomana, norange)
}

function methods:SetActive(state)
	self:SetAlphaFromBoolean(state, 0.2, 1)
end

function methods:SetCooldown(remaining, duration)
	-- incredibly wasteful to set cooldown state in here because it's called like 20 times/sec
	if (duration or 0) > 0 or (remaining or 0) > 0 then
		self.Cooldown:SetCooldown(GetTime() - (duration - remaining), duration)
		self.Icon:SetDesaturated(true)
		self.Icon:SetAlpha(1/3)
		self.Border:SetAlpha(1/3)
	else
		self.Icon:SetDesaturated(false)
		self.Icon:SetAlpha(1)
		self.Border:SetAlpha(1)
	end
end

function methods:SetCooldownPH(hintID)
	-- only spells have secret cooldowns, so OPie shouldn't ever need to call this for items or toys

	-- for some unknown reason, OPie appends ".5" to every hintID (which is the spellID), so
	-- we'll need to remove that before rendering the cooldown
	local spellID = math.floor(hintID)

	local charge = C_Spell.GetSpellChargeDuration(spellID)
	local duration = C_Spell.GetSpellCooldownDuration(spellID)

	-- reset before we try to render the "cooldown state"
	self.Cooldown:Hide()
	self.Border:SetAlpha(1)
	self.Icon:SetAlpha(1)
	self.Icon:SetDesaturation(0)

	if duration or charge then
		self.Cooldown:SetCooldownFromDurationObject(charge or duration)

		if duration then
			local alpha = duration:EvaluateRemainingDuration(addon.curves.ActionAlpha)
			self.Border:SetAlpha(alpha)
			self.Icon:SetAlpha(alpha)
			self.Icon:SetDesaturation(duration:EvaluateRemainingDuration(addon.curves.ActionDesaturation))
			self.Cooldown:SetDrawEdge(false)
			self.Cooldown:SetDrawSwipe(true)
		else
			self.Cooldown:SetDrawEdge(true)
			self.Cooldown:SetDrawSwipe(false)
		end
	end
end

function methods:SetDominantColor(r, g, b)
	self.Border:SetVertexColor(r, g, b)
end

function methods:SetHighlighted(state)
	self.Highlight:SetShown(state)
end

function methods:SetIcon(texture)
	self.Icon:SetTexture(texture)
end

function methods:SetIconAtlas(atlas)
	self.Icon:SetAtlas(atlas)
end

function methods:SetIconVertexColor(r, g, b)
	self.Icon:SetVertexColor(r, g, b)
end

local function constructor(_, parent, size)
	local Button = CreateFrame('CheckButton', nil, parent)
	Button:SetSize(size, size)

	local Icon = Button:CreateTexture(nil, 'BACKGROUND')
	Icon:SetAllPoints()
	Icon:SetMask(CIRCLE_MASK)
	Button.Icon = Icon

	local Cooldown = addon:CreateCooldown(Button)
	Cooldown:SetUseCircularEdge(true)
	Cooldown:SetSwipeTexture(CIRCLE_MASK)
	Cooldown:GetCountdownFontString():SetIgnoreParentAlpha(true)
	Cooldown:SetAlpha(1/3)
	Button.Cooldown = Cooldown

	-- render everything else above the cooldown
	local OverlayFrame = CreateFrame('Frame', nil, Button)
	OverlayFrame:SetAllPoints()

	local Border = OverlayFrame:CreateTexture(nil, 'OVERLAY')
	Border:ClearAllPoints()
	Border:SetPoint('TOPLEFT', Icon, -1, 1)
	Border:SetPoint('BOTTOMRIGHT', Icon, 1, -1)
	Border:SetTexture(CIRCLE_BORDER)
	Button.Border = Border

	local Highlight = OverlayFrame:CreateTexture(nil, 'OVERLAY')
	Highlight:SetAllPoints()
	Highlight:SetTexture(CIRCLE_MASK)
	Highlight:SetVertexColor(1, 1, 2/5, 1/4)
	Button.Highlight = Highlight

	return Mixin(Button, methods)
end

addon:HookAddOn('OPie', function()
	-- register skin
	OPie.UI:RegisterIndicatorConstructor(addonName, {
		name = addonName,
		apiLevel = 3,
		CreateIndicator = constructor,

		-- OPie requires opt-in support for secret handling of spell cooldowns
		supportsCooldownPH = true,
	})
end)
