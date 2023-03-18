local _, addon = ...

local NUM_TOTEMS = 4
local SPACING = 5.5 -- stupid pixel offsets
local WIDTH = (Minimap:GetWidth() - ((NUM_TOTEMS - 1) * SPACING)) / NUM_TOTEMS

local totemMixin = {}
function totemMixin:Update(slot)
	if slot ~= self:GetID() then
		return
	end

	local exists, _, _, _, texture = GetTotemInfo(slot)
	if exists then
		self:SetAlpha(1)
		self.texture:SetTexture(texture)
		self.texture:SetDesaturated(GetTotemCannotDismiss(slot))
	else
		self:SetAlpha(0)
	end
end

local totems = {}
for index = 1, NUM_TOTEMS do
	local totem = Mixin(addon:CreateButton('Button', nil, UIParent, 'SecureActionButtonTemplate'), totemMixin)
	totem:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', (index - 1) * (WIDTH + SPACING), -SPACING)
	totem:SetAttribute('type2', 'destroytotem')
	totem:SetAttribute('totem-slot', index)
	totem:SetSize(WIDTH, WIDTH / 2)
	totem:SetID(index)
	totem:RegisterEvent('PLAYER_TOTEM_UPDATE', totem.Update)

	addon:AddBackdrop(totem)

	local texture = totem:CreateTexture(nil, 'ARTWORK')
	texture:SetAllPoints()
	texture:SetTexCoord(0.08, 0.92, 0.28, 0.82)
	totem.texture = texture

	table.insert(totems, totem)
end

function addon:PLAYER_ENTERING_WORLD()
	for index, totem in next, totems do
		totem:Update(index)
	end
end
