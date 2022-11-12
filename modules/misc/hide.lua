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

-- chat frame buttons
addon:Hide('QuickJoinToastButton')
addon:Hide('ChatFrameChannelButton')
addon:Hide('ChatFrameMenuButton')
for index = 1, NUM_CHAT_WINDOWS do
	addon:Hide('ChatFrame' .. index .. 'ButtonFrame')
end
