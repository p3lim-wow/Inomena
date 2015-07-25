local Parent = CreateFrame('Frame', (...) .. 'ExtraBar', UIParent, 'SecureHandlerStateTemplate')
Parent:SetPoint('BOTTOM', _G[(...) .. 'ActionBar'], 0, 240)
Parent:SetSize(50, 50)

RegisterStateDriver(Parent, 'visibility', '[petbattle][overridebar][vehicleui] hide; show')

ExtraActionBarFrame:SetParent(Parent)
ExtraActionBarFrame:EnableMouse(false)
ExtraActionBarFrame:SetAllPoints()
ExtraActionBarFrame.ignoreFramePositionManager = true
