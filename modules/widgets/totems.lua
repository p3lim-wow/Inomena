local _, addon = ...

-- add totems below the minimap

local NUM_TOTEMS = 5 -- MAX_TOTEMS is incorrect
local WIDTH = math.floor((Minimap:GetWidth() - ((NUM_TOTEMS - 1) * addon.SPACING)) / MAX_TOTEMS)
-- ^ this is a shit calculation but it'll do for now

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

for index = 1, NUM_TOTEMS do
	local Totem = addon:CreateBackdropFrame('Button', nil, UIParent, 'SecureActionButtonTemplate')
	Totem:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', (index - 1) * (WIDTH + addon.SPACING), -addon.SPACING)
	Totem:SetAttribute('type2', 'destroytotem')
	Totem:SetAttribute('totem-slot', index)
	Totem:SetSize(WIDTH, WIDTH / 2)
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
end
