local _, Inomena = ...

VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()

UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

-- Stupid leftover by blizz, bugs out the new window a bit
FriendsFrameTab4:Hide()

function CombatLog_LoadUI() end
