local E, F, C = unpack(select(2, ...))

local Parent = CreateFrame('Frame', C.Name .. 'ExtraBarParent', UIParent, 'SecureHandlerStateTemplate')
Parent:SetPoint('BOTTOM', 0, 250)
Parent:SetSize(50, 50)

RegisterStateDriver(Parent, 'visibility', '[petbattle][overridebar][vehicleui] hide; show')

ExtraActionBarFrame:SetParent(Parent)
ExtraActionBarFrame:EnableMouse(false)
ExtraActionBarFrame:SetAllPoints()
ExtraActionBarFrame.ignoreFramePositionManager = true
