local _, addon = ...

-- hide misc crap
addon:Hide('TicketStatusFrame')
addon:Hide('DurabilityFrame')
addon:Hide('VehicleSeatIndicator')
addon:Hide('StanceBar')
addon:Hide('MainMenuBarVehicleLeaveButton')

-- order hall bar
addon:HookAddOn('Blizzard_OrderHallUI', function()
	addon:Hide('OrderHallCommandBar')
end)
