
for index = 1, MAX_BOSS_FRAMES do
	local frame = _G['Boss' .. index .. 'TargetFrame']
	frame:UnregisterAllEvents()
	frame:Hide()
end

UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

function CombatLog_LoadUI() end
