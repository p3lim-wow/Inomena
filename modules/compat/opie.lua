local addonName, addon = ...

-- skin opie

local CIRCLE_BORDER = addon.PATH .. 'circle'
local CIRCLE_MASK = [[Interface\CharacterFrame\TempPortraitAlphaMask]]

local methods = {}
function methods:SetIcon(texture)
	self.Icon:SetTexture(texture)
end

function methods:SetIconAtlas(atlas)
	self.Icon:SetAtlas(atlas)
end

function methods:SetIconVertexColor(r, g, b)
	self.Icon:SetVertexColor(r, g, b)
end

function methods:SetDominantColor(r, g, b)
	self.Border:SetVertexColor(r, g, b)
end

function methods:SetHighlighted(state)
	self.Highlight:SetShown(state)
end

function methods:SetActive(state)
	self:SetAlphaFromBoolean(state, 0.2, 1)
end

function methods:SetCooldown(remaining, duration)
	-- no clue why this isn't handled by OPie
	remaining = remaining or 0
	duration = duration or 0

	if duration > 0 or remaining > 0 then
		self.Cooldown:SetCooldown(GetTime() - (duration - remaining), duration)
		self.Icon:SetDesaturated(true)
		self.Icon:SetAlpha(1/3)
		self.Border:SetAlpha(1/3)
	else
		self.Cooldown:Hide()
		self.Icon:SetDesaturated(false)
		self.Icon:SetAlpha(1)
		self.Border:SetAlpha(1)
	end
end

function methods:SetCooldownDuration(duration, isRecharge)
	self.Cooldown:SetCooldownFromDurationObject(duration)
	self.Cooldown:SetDrawEdge(isRecharge)
	self.Cooldown:SetDrawSwipe(not isRecharge)

	if not isRecharge then
		local alpha = duration:EvaluateRemainingDuration(addon.curves.ActionAlpha)
		self.Border:SetAlpha(alpha)
		self.Icon:SetAlpha(alpha)
		self.Icon:SetDesaturation(duration:EvaluateRemainingDuration(addon.curves.ActionDesaturation))
	end
end

-- disable methods we don't support
for _, method in next, {
	'SetIconTexCoord', -- can't set coords when icon has mask
	'SetUsable',
	'SetOverlayIcon',
	'SetOverlayIconVertexColor',
	'SetCount',
	'SetBinding',
	'SetCooldownTextShown',
	'SetOuterGlow',
	'SetEquipState',
	'SetShortLabel',
	'SetQualityOverlay',
} do
	methods[method] = nop
end

local function constructor(_, parent, size)
	local Button = addon:CreateFrame('Frame', nil, parent)
	Button:SetSize(size, size)

	local Mask = Button:CreateMaskTexture()
	Mask:SetTexture(CIRCLE_MASK)
	Mask:SetAllPoints()

	local Icon = Button:CreateTexture('BACKGROUND')
	Icon:SetAllPoints()
	Icon:AddMaskTexture(Mask)
	Button.Icon = Icon

	local Cooldown = Button:CreateCooldown()
	Cooldown:SetUseCircularEdge(true)
	Cooldown:SetSwipeTexture(CIRCLE_MASK)
	Cooldown:SetSwipeColor(0, 0, 0, 0.6)
	Cooldown:GetCountdownFontString():SetIgnoreParentAlpha(true)
	Button.Cooldown = Cooldown

	-- render everything else above the cooldown
	local OverlayFrame = Button:CreateFrame('Frame')
	OverlayFrame:SetAllPoints()

	local Border = OverlayFrame:CreateTexture('OVERLAY')
	Border:ClearAllPoints()
	Border:SetPoint('TOPLEFT', Icon, -1, 1)
	Border:SetPoint('BOTTOMRIGHT', Icon, 1, -1)
	Border:SetTexture(CIRCLE_BORDER)
	Button.Border = Border

	local Highlight = OverlayFrame:CreateTexture('OVERLAY')
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
		apiLevel = 4,
		CreateIndicator = constructor,
	})
end)
