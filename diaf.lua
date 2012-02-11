local _, Inomena = ...

for index = 1, MAX_BOSS_FRAMES do
	local frame = _G['Boss' .. index .. 'TargetFrame']
	frame:UnregisterAllEvents()
	frame:Hide()
end

VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()

UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

-- Stupid leftover by blizz, bugs out the new window a bit
FriendsFrameTab4:Hide()

function CombatLog_LoadUI() end
