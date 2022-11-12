local _, addon = ...

addon:BindButton('Eject', '`'):SetScript('OnClick', function()
	for index = 1, UnitVehicleSeatCount('player') do
		if CanEjectPassengerFromSeat(index) then
			EjectPassengerFromSeat(index)
		end
	end
end)
