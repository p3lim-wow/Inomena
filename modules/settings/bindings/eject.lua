local _, addon = ...

-- ejects all passengers on a multi-seated mount

local button = addon:CreateBindButton('Eject')
button:Bind('`')
button:SetScript('OnClick', function()
	for index = 1, UnitVehicleSeatCount('player') do
		if CanEjectPassengerFromSeat(index) then
			EjectPassengerFromSeat(index)
		end
	end
end)
