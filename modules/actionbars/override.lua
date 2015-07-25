local E, F, C = unpack(select(2, ...))

local Parent = CreateFrame('Frame', (...) .. 'OverrideBar', UIParent, 'SecureHandlerStateTemplate')
Parent:SetPoint('BOTTOM', 0, 80)
Parent:SetSize(198, 33)

RegisterStateDriver(Parent, 'visibility', '[petbattle] hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide')
RegisterStateDriver(OverrideActionBar, 'visibility', '[overridebar][vehicleui][possessbar,@vehicle,exists] show; hide')

for index = 1, NUM_OVERRIDE_BUTTONS do
	local Button = _G['OverrideActionBarButton' .. index]
	Button:ClearAllPoints()

	if(index == 1) then
		Button:SetPoint('BOTTOMLEFT', Parent, 2, 0)
	else
		Button:SetPoint('LEFT', _G['OverrideActionBarButton' .. index - 1], 'RIGHT', 5, 0)
	end

	F:SkinActionButton(Button)
end

OverrideActionBar:SetParent(Parent)
OverrideActionBar:EnableMouse(false)
OverrideActionBar:SetScript('OnShow', nil)

local LeaveButton = CreateFrame('Button', Parent:GetName() .. 'Leave', Parent, 'ActionButtonTemplate, SecureActionButtonTemplate')
LeaveButton:SetPoint('LEFT', _G['OverrideActionBarButton' .. NUM_OVERRIDE_BUTTONS], 'RIGHT', 5, 0)
LeaveButton:SetAttribute('type', 'macro')
LeaveButton:SetAttribute('macrotext', '/leavevehicle')

F:SkinActionButton(LeaveButton, nil, true)

LeaveButton.icon:SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]])
LeaveButton.icon:SetTexCoord(1/5, 4/5, 1/5, 4/5)
