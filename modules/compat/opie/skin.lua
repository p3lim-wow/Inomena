local addonName, addon = ...

local PORTRAIT_MASK = [[Interface\CharacterFrame\TempPortraitAlphaMask]]
local CIRCLE_BORDER = ([[Interface\AddOns\%s\assets\circle]]):format(addonName)

local methods = {
	-- pulled from OPie/Libs/Mirage.lua, indicatorAPI table methods
	SetIcon = nop, -- (texture, aspect)
	SetIconAtlas = nop, -- (atlas, aspect)
	SetIconTexCoord = nop, -- (a,b,c,d, e,f,g,h)
	SetIconVertexColor = nop, -- (r,g,b)
	SetUsable = nop, -- (usable, _usableCharge, _cd, nomana, norange)
	SetDominantColor = nop, -- (r,g,b)
	SetOverlayIcon = nop, -- (texture, w, h, ...)
	SetOverlayIconVertexColor = nop, -- (...)
	SetCount = nop, -- (count)
	SetBinding = nop, -- (binding)
	SetCooldown = nop, -- (remain, duration, usable)
	SetCooldownTextShown = nop, -- (cooldownShown, rechargeShown)
	SetHighlighted = nop, -- (highlight)
	SetActive = nop, -- (active)
	SetOuterGlow = nop, -- (shown)
	SetEquipState = nop, -- (isInContainer, isInInventory)
	SetShortLabel = nop, -- (text)
	SetQualityOverlay = nop, -- (qual)
}

function methods:SetIconVertexColor(r, g, b)
	self.Texture:SetVertexColor(r, g, b)
end

function methods:SetDominantColor(r, g, b)
	self.Border:SetVertexColor(r, g, b)
end

function methods:SetIcon(texture)
	self.Texture:SetTexture(texture)
end

function methods:SetHighlighted(highlight)
	self.Highlight:SetShown(highlight)
end

function methods:SetActive(state)
	self:SetAlpha(state and 0.2 or 1)
end

do
	local FORMAT = {
		days = '%dd',
		hours = '%dh',
		minutes = '%dm',
		seconds = '%.1fs',
	}

	local function cooldownFormat(duration)
		if (duration or 0) == 0 then
			return ''
		end

		if duration > 86400 then
			return FORMAT.days:format(math.ceil(duration / 86400))
		elseif duration > 3600 then
			return FORMAT.hours:format(math.ceil(duration / 3600))
		elseif duration > 60 then
			return FORMAT.minutes:format(math.ceil(duration / 60))
		else
			-- return FORMAT.seconds:format(math.ceil(duration))
			return FORMAT.seconds:format(duration)
		end
	end

	function methods:SetCooldown(remaining, duration)
		if (duration or 0) <= 0 or (remaining or 0) <= 0 then
			self.Texture:SetAlpha(1)
			self.Border:SetAlpha(1)
			self.Cooldown:SetText('')
		else
			self.Texture:SetAlpha(0.2)
			self.Border:SetAlpha(0.2)
			self.Cooldown:SetText(cooldownFormat(remaining))
		end
	end
end

local function constructor(name, parent, size)
	local button = CreateFrame('CheckButton', name, parent)
	button:SetSize(size, size)

	local texture = button:CreateTexture('$parentIcon', 'BACKGROUND')
	texture:SetAllPoints()
	texture:SetMask(PORTRAIT_MASK)
	button.Texture = texture

	local border = button:CreateTexture('$parentBorder', 'OVERLAY')
	border:ClearAllPoints()
	border:SetPoint('TOPLEFT', texture, -1, 1)
	border:SetPoint('BOTTOMRIGHT', texture, 1, -1)
	border:SetTexture(CIRCLE_BORDER)
	button.Border = border

	local highlight = button:CreateTexture(nil, 'OVERLAY')
	highlight:SetAllPoints()
	highlight:SetTexture(PORTRAIT_MASK)
	highlight:SetVertexColor(1, 1, 2/5, 1/4)
	button.Highlight = highlight

	-- TODO: add cooldown spiral?

	local cooldownText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLargeOutline')
	cooldownText:SetPoint('CENTER')
	button.Cooldown = cooldownText

	return Mixin(button, methods)
end

addon:HookAddOn('OPie', function()
	-- register skin
	OPie.UI:RegisterIndicatorConstructor(addonName, {
		name = addonName,
		apiLevel = 3,
		CreateIndicator = constructor,
	})
end)
