local _, addon = ...

local eject = addon:CreateButton('BindEject')
eject:RegisterEvent('PLAYER_LOGIN', function(self)
	SetBindingClick('`', self:GetName())

	return true
end)

eject:SetScript('OnClick', function()
	for index = 1, UnitVehicleSeatCount('player') do
		if CanEjectPassengerFromSeat(index) then
			EjectPassengerFromSeat(index)
		end
	end
end)
