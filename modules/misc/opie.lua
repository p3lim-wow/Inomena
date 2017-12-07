local E = unpack(select(2, ...))

local PORTRAIT_MASK = [[Interface\CharacterFrame\TempPortraitAlphaMask]]
local CIRCLE = [[Interface\AddOns\Inomena\assets\circle]]

local methods = {
	SetOverlayIcon = nop,
	SetOuterGlow = nop,
	SetBinding = nop,
	SetEquipState = nop,
	SetActive = nop,
	SetCooldownTextShown = nop,
	SetIconTexCoord = nop,
	SetCooldown = nop,
	SetCount = nop,
	SetUsable = nop
}

function methods:SetIconVertexColor(r, g, b)
	self.Icon:SetVertexColor(r, g, b)
end

function methods:SetDominantColor(r, g, b)
	self.NormalTexture:SetVertexColor(r, g, b)
end

function methods:SetIcon(texture)
	self.Icon:SetTexture(texture)
end

function methods:SetHighlighted(highlight)
	self.Highlight:SetShown(highlight)
end

local buttonIndex = 0
local function Constructor(name, parent, size, ...)
	-- these should have been set in OPie
	buttonIndex = buttonIndex + 1
	name = name or 'OPieSliceButton' .. buttonIndex
	parent = parent or UIParent
	size = size or 36

	local Button = CreateFrame('CheckButton', name, parent, 'ActionButtonTemplate')
	Button:SetSize(size, size)
	Button:EnableMouse(false)

	local Icon = _G[name .. 'Icon']
	Icon:SetMask(PORTRAIT_MASK)
	Button.Icon = Icon

	local NormalTexture = _G[name .. 'NormalTexture']
	NormalTexture:ClearAllPoints()
	NormalTexture:SetPoint('TOPLEFT', Icon, -1, 1)
	NormalTexture:SetPoint('BOTTOMRIGHT', Icon, 1, -1)
	NormalTexture:SetTexture(CIRCLE)
	Button.NormalTexture = NormalTexture

	local Highlight = Button:CreateTexture(nil, 'OVERLAY')
	Highlight:SetAllPoints()
	Highlight:SetTexture(PORTRAIT_MASK)
	Highlight:SetVertexColor(1, 1, 2/5, 1/4)
	Button.Highlight = Highlight

	for key, method in next, methods do
		Button[key] = method
	end

	return Button
end

function E:ADDON_LOADED(addon)
	if(addon == 'OPie') then
		OneRingLib.ext.OPieUI:SetIndicatorConstructor(Constructor)
		return true
	end
end
