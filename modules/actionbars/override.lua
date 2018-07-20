local E, F, C = unpack(select(2, ...))

local SPACING = C.BUTTON_SPACING
local SIZE = C.BUTTON_SIZE

local Parent = CreateFrame('Frame', C.Name .. 'OverrideBarParent', UIParent, 'SecureHandlerStateTemplate')
Parent:SetPoint('BOTTOMLEFT', _G[(...) .. 'ActionParent'])
Parent:SetSize(((NUM_OVERRIDE_BUTTONS + 1) * (SIZE + SPACING)) - SPACING, SIZE)

RegisterStateDriver(Parent, 'visibility', '[overridebar][vehicleui][possessbar,@vehicle,exists] show; hide')

for index = 1, NUM_OVERRIDE_BUTTONS do
	local Button = _G['OverrideActionBarButton' .. index]
	F:SkinActionButton(Button)

	Button:ClearAllPoints()
	Button:SetPoint('BOTTOMLEFT', Parent, (Button:GetWidth() + SPACING) * (index - 1), 0)
end

local LeaveButton = CreateFrame('Button', Parent:GetName() .. 'Leave', Parent, 'ActionButtonTemplate, SecureActionButtonTemplate')
LeaveButton:SetPoint('BOTTOMRIGHT', Parent)
LeaveButton:SetAttribute('type', 'macro')
LeaveButton:SetAttribute('macrotext', '/leavevehicle')

F:SkinActionButton(LeaveButton, nil, true)

LeaveButton.icon:SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]])
LeaveButton.icon:SetTexCoord(1/5, 4/5, 1/5, 4/5)
