local __, Inomena = ...

VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()

UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

hooksecurefunc('StaticPopup_Show', function(which)
	if(which == 'DEATH' and not UnitIsDead('player')) then
		StaticPopup_Hide(which)
	end
end)
