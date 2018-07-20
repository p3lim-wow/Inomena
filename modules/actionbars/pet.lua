local E, F, C = unpack(select(2, ...))

local SPACING = C.BUTTON_SPACING
local SIZE = C.BUTTON_SIZE - 5

local Parent = CreateFrame('Frame', C.Name .. 'PetBarParent', UIParent, 'SecureHandlerStateTemplate')
Parent:SetPoint('BOTTOM', _G[(...) .. 'ActionParent'], 'TOP', 0, SPACING)
Parent:SetSize((NUM_PET_ACTION_SLOTS * (SIZE + SPACING)) - SPACING, SIZE)

RegisterStateDriver(Parent, 'visibility', '[petbattle][overridebar][vehicleui][possessbar] hide; [@pet,exists] show; hide')

local function UpdateBorder(self)
	local index = self:GetID()

	local _, _, _, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(index)
	if(autoCastEnabled) then
		self:SetBackdropBorderColor(1, 1, 0)
	elseif(autoCastAllowed) then
		self:SetBackdropBorderColor(1/3, 1/3, 1/3)
	elseif(isActive) then
		self:SetBackdropBorderColor(0, 1/2, 1)
	else
		self:SetBackdropBorderColor(0, 0, 0)
	end
end

for index = 1, NUM_PET_ACTION_SLOTS do
	local Button = _G['PetActionButton' .. index]
	F:SkinActionButton(Button, true)

	Button:SetParent(Parent)
	Button:ClearAllPoints()
	Button:SetPoint('BOTTOMLEFT', Parent, (Button:GetWidth() + C.BUTTON_SPACING) * (index - 1), 0)

	hooksecurefunc(Button, 'SetChecked', UpdateBorder)
end

PetActionBarFrame:SetParent(Parent)
PetActionBarFrame:EnableMouse(false)
