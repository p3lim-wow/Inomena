local _, addon = ...

-- add totems above the 3rd bar (I really wish this could be part of CDM)

local NUM_TOTEMS = 5 -- MAX_TOTEMS is incorrect
local WIDTH = 44

local function update(self, slot)
	if slot ~= self:GetID() then
		return
	end

	local exists, _, _, _, texture = GetTotemInfo(slot)
	self:SetAlphaFromBoolean(exists, 1, 0)
	self.Texture:SetTexture(texture)
	self.Texture:SetDesaturated(GetTotemCannotDismiss(slot))

	local duration = GetTotemDuration(slot)
	if duration ~= nil then
		self.Duration:SetTimerDuration(duration) -- TODO: this is not very smooth
	end
end

local parent = CreateFrame('Frame', nil, UIParent)
parent:SetHeight(1)
parent:SetPoint('BOTTOM', MultiBarBottomRight, 'TOP', 0, addon.SPACING + 3)
-- TODO: this might collide with pet bar

for index = 1, NUM_TOTEMS do
	local Totem = addon:CreateBackdropFrame('Button', nil, parent, 'SecureActionButtonTemplate')
	Totem:SetPoint('BOTTOMLEFT', (index - 1) * (WIDTH + addon.SPACING), -addon.SPACING)
	Totem:SetSize(WIDTH, WIDTH / 2)
	Totem:SetAttribute('type2', 'destroytotem')
	Totem:SetAttribute('totem-slot', index)
	Totem:SetID(index)
	Totem:RegisterEvent('PLAYER_TOTEM_UPDATE', update)
	Totem:RegisterEvent('PLAYER_ENTERING_WORLD', GenerateFlatClosure(update, Totem, index))
	addon:PixelPerfect(Totem)

	local Texture = Totem:CreateTexture('ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexCoord(0.08, 0.92, 0.28, 0.82)
	Totem.Texture = Texture

	local Duration = Totem:CreateStatusBar()
	Duration:SetAllPoints()
	Duration:SetStatusBarColor(0, 0, 0, 0.7)
	Totem.Duration = Duration

	parent:SetWidth(parent:GetWidth() + Totem:GetWidth() + addon.SPACING)
end
